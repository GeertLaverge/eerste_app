// THIMACO-CONTROLE: NATIVE-IOS-MAILCOMPOSER-DAGELIJKSE-IMAP-20260802

import Flutter
import MessageUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
  MFMailComposeViewControllerDelegate
{
  private static let mailKanaalNaam = "be.thimaco.app/offerte_mail"
  private var mailResultaat: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let mailKanaal = FlutterMethodChannel(
      name: Self.mailKanaalNaam,
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    mailKanaal.setMethodCallHandler { [weak self] call, result in
      guard call.method == "openMailComposer" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.openMailComposer(call: call, result: result)
    }
  }

  private func openMailComposer(
    call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    guard mailResultaat == nil else {
      result(
        FlutterError(
          code: "MAIL_REEDS_OPEN",
          message: "Er staat al een iPad-mailvenster open.",
          details: nil
        )
      )
      return
    }

    guard MFMailComposeViewController.canSendMail() else {
      result(
        FlutterError(
          code: "GEEN_MAILACCOUNT",
          message:
            "Op deze iPad is geen bruikbaar account in Apple Mail ingesteld. " +
            "Controleer Instellingen → Apps → Mail → Mail-accounts.",
          details: nil
        )
      )
      return
    }

    guard let argumenten = call.arguments as? [String: Any] else {
      result(
        FlutterError(
          code: "ONGELDIGE_ARGUMENTEN",
          message: "De mailgegevens konden niet worden gelezen.",
          details: nil
        )
      )
      return
    }

    let ontvangers = argumenten["ontvangers"] as? [String] ?? []
    let onderwerp = argumenten["onderwerp"] as? String ?? ""
    let bericht = argumenten["bericht"] as? String ?? ""
    let bijlagen = argumenten["bijlagen"] as? [[String: Any]] ?? []

    let composer = MFMailComposeViewController()
    composer.mailComposeDelegate = self
    composer.setToRecipients(ontvangers)
    composer.setSubject(onderwerp)
    composer.setMessageBody(bericht, isHTML: false)

    for bijlage in bijlagen {
      guard let typedData = bijlage["bytes"] as? FlutterStandardTypedData else {
        continue
      }

      let bestandsnaam =
        (bijlage["bestandsnaam"] as? String)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? "document.pdf"

      let contentType =
        (bijlage["contentType"] as? String)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? "application/pdf"

      composer.addAttachmentData(
        typedData.data,
        mimeType: contentType.isEmpty ? "application/pdf" : contentType,
        fileName: bestandsnaam.isEmpty ? "document.pdf" : bestandsnaam
      )
    }

    guard let presentator = bovensteViewController() else {
      result(
        FlutterError(
          code: "GEEN_PRESENTATOR",
          message: "Het iPad-mailvenster kon niet worden weergegeven.",
          details: nil
        )
      )
      return
    }

    mailResultaat = result
    presentator.present(composer, animated: true)
  }

  func mailComposeController(
    _ controller: MFMailComposeViewController,
    didFinishWith result: MFMailComposeResult,
    error: Error?
  ) {
    controller.dismiss(animated: true) { [weak self] in
      guard let self = self else {
        return
      }

      let flutterResultaat = self.mailResultaat
      self.mailResultaat = nil

      if let error = error {
        flutterResultaat?(
          FlutterError(
            code: "MAIL_FOUT",
            message:
              "De e-mail kon niet worden afgewerkt: " +
              error.localizedDescription,
            details: nil
          )
        )
        return
      }

      switch result {
      case .sent:
        flutterResultaat?("sent")
      case .saved:
        flutterResultaat?("saved")
      case .cancelled:
        flutterResultaat?("cancelled")
      case .failed:
        flutterResultaat?(
          FlutterError(
            code: "MAIL_MISLUKT",
            message: "De iPad-mailapp kon de e-mail niet versturen.",
            details: nil
          )
        )
      @unknown default:
        flutterResultaat?(
          FlutterError(
            code: "MAIL_ONBEKEND",
            message: "De iPad-mailapp gaf een onbekend resultaat terug.",
            details: nil
          )
        )
      }
    }
  }

  private func bovensteViewController(
    vanaf basis: UIViewController? = nil
  ) -> UIViewController? {
    let startController: UIViewController?

    if let basis = basis {
      startController = basis
    } else {
      let actiefVenster = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }

      startController = actiefVenster?.rootViewController
    }

    if let navigation = startController as? UINavigationController {
      return bovensteViewController(vanaf: navigation.visibleViewController)
    }

    if let tabs = startController as? UITabBarController {
      return bovensteViewController(vanaf: tabs.selectedViewController)
    }

    if let gepresenteerd = startController?.presentedViewController {
      return bovensteViewController(vanaf: gepresenteerd)
    }

    return startController
  }
}