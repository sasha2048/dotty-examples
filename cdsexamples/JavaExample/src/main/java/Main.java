package cdsexamples;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello from Java !");
        if (args.length > 0) {
            System.out.println(VMOptions.asString());
            //ScriptEngineTest.run();  // .jsa file size: 9 Mb -> 24 Mb !
        }
    }
}
