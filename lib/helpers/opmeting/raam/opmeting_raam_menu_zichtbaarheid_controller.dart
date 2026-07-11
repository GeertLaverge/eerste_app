class OpmetingRaamMenuZichtbaarheidController {
  bool vleugelMenuZichtbaar = true;
  bool tStijlMenuZichtbaar = true;
  bool opvullingMenuZichtbaar = true;
  bool kleinhoutMenuZichtbaar = true;

  bool verwerkToolWijziging({
    required String oudeTool,
    required String nieuweTool,
  }) {
    if (oudeTool == nieuweTool) {
      return false;
    }

    switch (nieuweTool) {
      case 'vleugel':
        vleugelMenuZichtbaar = true;
        break;

      case 'tstijl':
        tStijlMenuZichtbaar = true;
        break;

      case 'opvulling':
        opvullingMenuZichtbaar = true;
        return true;

      case 'kleinhout':
        kleinhoutMenuZichtbaar = true;
        break;
    }

    return false;
  }

  bool verwerkMenuOpenSignalen({
    required String actieveTool,
    required int oudVleugelSignaal,
    required int nieuwVleugelSignaal,
    required int oudTStijlSignaal,
    required int nieuwTStijlSignaal,
    required int oudOpvullingSignaal,
    required int nieuwOpvullingSignaal,
    required int oudKleinhoutSignaal,
    required int nieuwKleinhoutSignaal,
  }) {
    if (actieveTool == 'vleugel' && oudVleugelSignaal != nieuwVleugelSignaal) {
      vleugelMenuZichtbaar = true;
    }

    if (actieveTool == 'tstijl' && oudTStijlSignaal != nieuwTStijlSignaal) {
      tStijlMenuZichtbaar = true;
    }

    if (actieveTool == 'opvulling' &&
        oudOpvullingSignaal != nieuwOpvullingSignaal) {
      opvullingMenuZichtbaar = true;
      return true;
    }

    if (actieveTool == 'kleinhout' &&
        oudKleinhoutSignaal != nieuwKleinhoutSignaal) {
      kleinhoutMenuZichtbaar = true;
    }

    return false;
  }

  void toonVleugelMenu() {
    vleugelMenuZichtbaar = true;
  }

  void toonTStijlMenu() {
    tStijlMenuZichtbaar = true;
  }

  void toonOpvullingMenu() {
    opvullingMenuZichtbaar = true;
  }

  void toonKleinhoutMenu() {
    kleinhoutMenuZichtbaar = true;
  }

  void sluitVleugelMenu() {
    vleugelMenuZichtbaar = false;
  }

  void sluitTStijlMenu() {
    tStijlMenuZichtbaar = false;
  }

  void sluitOpvullingMenu() {
    opvullingMenuZichtbaar = false;
  }

  void sluitKleinhoutMenu() {
    kleinhoutMenuZichtbaar = false;
  }
}
