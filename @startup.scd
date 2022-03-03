//superssq, superstri, superssin, supersfm
//supersklm, superspno, supersharpsi, supersharpsi2, supersrhodes,supersrhodes2
//superglk, superspbell, supersprisset, supersrbell, superssosbell, superschimes
//superssaw, superswarsaw
//superstriwave, supersmoogb, supersmoogb2, superspwm, superswhoorgan

Server.killAll;
Platform.systemExtensionDir

Quarks.gui
SynthDescLib.global.browse;
s.quit
s.boot;
s.meter;
s.scope;
x.free;
x = {Out.ar(0, Pan2.ar(SoundIn.ar(0)))}.play;
this.executeFile("/home/dxk/tidalstuff/superdirt_startup.scd");

~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/perc/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/melodic/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/human/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/elec/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/glass/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/mech/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/sfx/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/car/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/note/*");
~dirt.loadSoundFiles("/home/dxk/sounds/melodic/*");
~dirt.loadSoundFiles("/home/dxk/sounds/animal/*");

~dirt.loadSoundFiles("/home/dxk/sounds/melodic2/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/car/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/bus/*");
~dirt.loadSoundFiles("/home/dxk/sounds/atmos/*");
~dirt.loadSoundFiles("/home/dxk/sounds/transport/*");

~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/bugs/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/misc/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/note/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/human/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/bugs/*");
~dirt.loadSoundFiles("/home/dxk/sounds/speech/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/animal/cat/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/my_voice");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/pitched/*");

~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/animal/cat/*");
~dirt.loadSoundFiles("/home/dxk/sounds/animal/birds/*");
~dirt.loadSoundFiles("/home/dxk/sounds/animal/*");
~dirt.loadSoundFiles("/home/dxk/sounds/machine/*");
~dirt.loadSoundFiles("/home/dxk/sounds/elec/*");
~dirt.loadSoundFiles("/home/dxk/sounds/radio/*");
~dirt.loadSoundFiles("/home/dxk/sounds/tv/*");
~dirt.loadSoundFiles("/home/dxk/sounds/animal/*");
~dirt.loadSoundFiles("/home/dxk/sounds/oneshot/comp/*");


~loadsynths.value;

~input = Synth(\dxkM2S, [\out, 20], addAction: \addToHead);
~rvb = Synth(\dxkFreeVerbS, [\in, 20, \out, 0], addAction: \addToTail);
~rvb.set(\mix, 0.9, \room, 0.99, \damp, 0.33);
~input.free; ~rvb.free;
SuperDirt.start;
Quarks.gui;
s.quit;
s.meter;
s.scope;
Platform.userExtensionDir

Platform.systemExtensionDir

MIDIClient.init;
~midiOut = MIDIOut.newByName("Pure Data", "Pure Data Midi-In 1");
~midiOut = MIDIOut.newByName("Midi Through", "Midi Through Port-0");
~dirt.soundLibrary.addMIDI(\midi, ~midiOut);

//~dirt.soundLibrary.addMIDI(\midipd, ~midiOut);
