
SynthDef(\superssq, {|out, rate=1, decay=0, sustain=1, pan, accelerate, freq, lopprop = 100, duty = 0.5|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
	    var lopfreq = basefreq * lopprop;
	    var sig = LPF.ar(Pulse.ar(basefreq, duty), Clip.kr(lopfreq, 0, 20000));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\superstri, {|out, rate=1, decay=0, sustain=1, pan, accelerate, freq, lopprop = 100, duty = 0.5|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
	    var lopfreq = basefreq * lopprop;
	    var sig = LPF.ar(VarSaw.ar(basefreq, 0,  duty), Clip.kr(lopfreq, 0, 20000));
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;


SynthDef(\superssin, {|out, rate=1, decay=0, sustain=1, pan, accelerate, freq|
		var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
		var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
	    var sig = SinOsc.ar(basefreq);
		OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

SynthDef(\supersfm, {|out, rate = 1, decay = 0, sustain = 1, pan, accelerate, freq, modidx = 1, modharm = 1|
	var env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -3), timeScale:sustain, doneAction:2);
	var basefreq = freq* Line.kr(1, 1+accelerate, sustain);
	var modfreq = basefreq * modharm;
	var mod = SinOsc.ar(modfreq,0, modfreq * modidx);
	var sig = SinOsc.ar(mod + basefreq);
	OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env));
}).add;

//snappizz's kalimba
SynthDef(\supersklm, {
    |out, freq, voice = 0.1, pan, sustain=1|
    var snd, click, env;
    // Basic tone is a SinOsc
	env = EnvGen.ar(Env.perc(0.03, Rand(3.0, 4.0), 1, -7), timeScale: sustain, doneAction: 2);
    snd = SinOsc.ar(freq) * env;
	snd = HPF.ar( LPF.ar(snd, 380), 120);
    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped white noise
	click = DynKlank.ar(`[
        // the resonant frequencies are randomized a little to add variation
        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
        [240*ExpRand(0.97, 1.02), 2020*ExpRand(0.97, 1.02), 3151*ExpRand(0.97, 1.02)],
        [-9, 0, -5].dbamp,
        [0.8, 0.07, 0.08]
	], BPF.ar(PinkNoise.ar, 6500, 0.1) * EnvGen.ar(Env.perc(0.001, 0.01))) * 0.1;
	snd = (snd*voice) + (click*(1-voice));
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));

}).add;

//snappizz's rhodey_sc
SynthDef(\supersrhodes, {
    |
    // standard meanings
    out, freq, gate = 1, pan, sustain = 1,
    // all of these range from 0 to 1
    voice = 0.2, rate = 0.4, lfo = 0.1,
	att = 0.001, decay = 1.5, rel = 0.1
    |
    var env1, env2, env3, env4, env;
    var osc1, osc2, osc3, osc4, snd;
	var amp = 0.1, vel = 0.8;

    rate = rate * 12;

    env1 = EnvGen.ar(Env.perc(att, 0.833*decay + 0.04 + rel, curve: \lin));
    env2 = EnvGen.ar(Env.perc(att, 0.667*decay + 0.04 + rel, curve: \lin));
    env3 = EnvGen.ar(Env.perc(att, decay + 0.04 + rel, curve: \lin));
    env4 = EnvGen.ar(Env.perc(att, decay + 0.04 + rel, curve: \lin), timeScale: sustain, doneAction: 2);

    osc4 = SinOsc.ar(freq) * 2pi * 2 * 0.535887 * voice * env4 * vel;
    osc3 = SinOsc.ar(freq * 2, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 30) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq * 2, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - voice)) + (osc1 * voice));
    snd = snd * (SinOsc.ar(rate) * lfo + 1);

    // using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
    snd = snd * amp;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env4));

}).add;

