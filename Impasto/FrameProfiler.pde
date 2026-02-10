class FrameProfiler {
    float startTime;
    ArrayList<Entry> logs;

    FrameProfiler() {
        logs = new ArrayList<Entry>();
    }

    void Start() {
        startTime = millis();
        logs.clear();
    }

    void AddEntry(String name) {
        Entry e = new Entry();
        e.name = name;
        e.time = millis() - GetPreviousTime();
        logs.add(e);
    }


    float GetPreviousTime() {
        if (logs.size() == 0) {
            return startTime;
        }
        return startTime + logs.get(logs.size() - 1).time;
    }

    class Entry{
        public String name;
        public float time;        
    }
}
