class KeyboardInput {

  int z = 90;
  int x = 88;
  int c = 67;
  int v = 86;
  int s = 83;
  ArrayList<Character> heldKeys;
  ArrayList<Integer> keyCodes;

  KeyboardInput() {
    heldKeys = new ArrayList<Character>();
    keyCodes = new ArrayList<Integer>();
  }

  boolean isKeyHeld(char k) {
    return heldKeys.contains(k);
  }

  void DrawKeyboardInput() {
    fill(0);
    textAlign(LEFT, BOTTOM);
    text("Held Keys: " + heldKeys + " | Held KeyCodes: " + keyCodes, 10, height - 100);
  }

  void Add(int kc) {
    if (!keyCodes.contains(kc)) {
      keyCodes.add(kc);
    }
  }

  void Add(char k) {
    if (!heldKeys.contains(k)) {
      heldKeys.add(k);
    }
  }

  void Remove(int kc) {
    keyCodes.remove(Integer.valueOf(kc));
  }

  void Remove(char k) {
    heldKeys.remove(Character.valueOf(k));
  }

  boolean Contains(int kc) {
    return keyCodes.contains(kc);
  }
  boolean Contains(char k) {
    return heldKeys.contains(k);
  }
}