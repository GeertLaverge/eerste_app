// THIMACO-CONTROLE: FINANCIELE-KLUIS-NATIVE-PRIVACY-SCHILD-20260806
// THIMACO-CONTROLE: NATIVE-IOS-MAILCOMPOSER-DAGELIJKSE-IMAP-20260802

import Flutter
import MessageUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate,
  MFMailComposeViewControllerDelegate
{
  private static let mailKanaalNaam = "be.thimaco.app/offerte_mail"
  private static let privacyKanaalNaam = "be.thimaco.app/financiele_privacy"
  private static let privacySchildTag = 0x54484D46

  private var mailResultaat: FlutterResult?
  private var financieelSchermActief = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWordtInactief(_:)),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func didInitializeImplicitFlutterEngine(
    _ engineBridge: FlutterImplicitEngineBridge
  ) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    let mailKanaal = FlutterMethodChannel(
      name: Self.mailKanaalNaam,
      binaryMessenger: messenger
    )

    mailKanaal.setMethodCallHandler { [weak self] call, result in
      guard call.method == "openMailComposer" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.openMailComposer(call: call, result: result)
    }

    let privacyKanaal = FlutterMethodChannel(
      name: Self.privacyKanaalNaam,
      binaryMessenger: messenger
    )

    privacyKanaal.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(
          FlutterError(
            code: "PRIVACY_GEEN_APPDELEGATE",
            message: "Het financiële privacyschild is niet beschikbaar.",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "setSensitiveScreenActive":
        let actief = call.arguments as? Bool ?? false
        self.financieelSchermActief = actief

        if !actief {
          self.verwijderPrivacySchild()
        }

        result(nil)

      case "hidePrivacyShield":
        self.verwijderPrivacySchild()
        result(nil)

      case "excludeFromBackup":
        guard let pad = call.arguments as? String, !pad.isEmpty else {
          result(
            FlutterError(
              code: "PRIVACY_ONGELDIG_PAD",
              message: "Het financiële opslagpad ontbreekt.",
              details: nil
            )
          )
          return
        }

        do {
          var waarden = URLResourceValues()
          waarden.isExcludedFromBackup = true
          var url = URL(fileURLWithPath: pad, isDirectory: true)
          try url.setResourceValues(waarden)
          result(true)
        } catch {
          result(
            FlutterError(
              code: "PRIVACY_BACKUP_UITSLUITEN_MISLUKT",
              message:
                "De financiële opslag kon niet van iOS-reservekopieën worden uitgesloten.",
              details: error.localizedDescription
            )
          )
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @objc private func appWordtInactief(_ melding: Notification) {
    guard financieelSchermActief else {
      return
    }

    toonPrivacySchild()
  }

  private func toonPrivacySchild() {
    let werk = {
      for venster in self.alleZichtbareVensters() {
        if venster.viewWithTag(Self.privacySchildTag) != nil {
          continue
        }

        venster.endEditing(true)

        let schild = UIView(frame: venster.bounds)
        schild.tag = Self.privacySchildTag
        schild.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        schild.backgroundColor = UIColor(
          red: 11.0 / 255.0,
          green: 122.0 / 255.0,
          blue: 59.0 / 255.0,
          alpha: 1.0
        )

        let icoon = UIImageView(
          image: UIImage(systemName: "lock.shield.fill")
        )
        icoon.tintColor = .white
        icoon.contentMode = .scaleAspectFit
        icoon.translatesAutoresizingMaskIntoConstraints = false
        icoon.widthAnchor.constraint(equalToConstant: 58).isActive = true
        icoon.heightAnchor.constraint(equalToConstant: 58).isActive = true

        let titel = UILabel()
        titel.text = "Financiële kluis vergrendeld"
        titel.textColor = .white
        titel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titel.textAlignment = .center
        titel.numberOfLines = 0

        let uitleg = UILabel()
        uitleg.text = "Open de app opnieuw en bevestig met Face ID."
        uitleg.textColor = UIColor.white.withAlphaComponent(0.88)
        uitleg.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        uitleg.textAlignment = .center
        uitleg.numberOfLines = 0

        let stapel = UIStackView(arrangedSubviews: [icoon, titel, uitleg])
        stapel.axis = .vertical
        stapel.alignment = .center
        stapel.spacing = 12
        stapel.translatesAutoresizingMaskIntoConstraints = false

        schild.addSubview(stapel)
        venster.addSubview(schild)
        venster.bringSubviewToFront(schild)

        NSLayoutConstraint.activate([
          stapel.centerXAnchor.constraint(equalTo: schild.centerXAnchor),
          stapel.centerYAnchor.constraint(equalTo: schild.centerYAnchor),
          stapel.leadingAnchor.constraint(
            greaterThanOrEqualTo: schild.leadingAnchor,
            constant: 28
          ),
          stapel.trailingAnchor.constraint(
            lessThanOrEqualTo: schild.trailingAnchor,
            constant: -28
          ),
        ])
      }
    }

    if Thread.isMainThread {
      werk()
    } else {
      DispatchQueue.main.async(execute: werk)
    }
  }

  private func verwijderPrivacySchild() {
    let werk = {
      for venster in self.alleZichtbareVensters() {
        venster.viewWithTag(Self.privacySchildTag)?.removeFromSuperview()
      }
    }

    if Thread.isMainThread {
      werk()
    } else {
      DispatchQueue.main.async(execute: werk)
    }
  }

  private func alleZichtbareVensters() -> [UIWindow] {
    return UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .filter { !$0.isHidden && $0.alpha > 0 }
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