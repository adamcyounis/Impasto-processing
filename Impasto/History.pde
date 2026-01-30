class History {
  ArrayList<Canvas> states;
  int limit = 200;
  int index = -1;

  History() {
    states = new ArrayList<Canvas>();
  }

  void AddState(Canvas state) {
    //if index != last index, remove all states after index
    if (index < states.size() - 1) {
      states.subList(index + 1, states.size()).clear();
    }

    //if we are at the limit, remove the oldest state
    if (states.size() >= limit) {
      states.remove(0);
    }

    //add the new state
    states.add(state.Clone());
    index = states.size() - 1;
  }

  void  Undo() {
    if (states.size() > 0 && index > 0) {
      index--;
    }
  }

  void Redo() {
    if (index < states.size() - 1) {
      index++;
    }
  }

  void CheckUndoRedoKeys() {
    if (keyPressed) {
      //check ctrl
      if (keys.Contains(CONTROL) && (keys.Contains(keys.z))) {

        if (keys.Contains(SHIFT)) {
          Redo();
        } else {
          Undo();
        }
      }
    }
  }

  Canvas GetCurrent() {
    return states.get(index);
  }
}