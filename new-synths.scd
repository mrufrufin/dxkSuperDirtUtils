//superssq, superstri, superssin, supersfm
//supersklm, superspno, supersharpsi, supersharpsi2, supersrhodes
//superglk, superspbell, supersprisset, supersrbell, superssosbell, superschimes
//superssaw, superswarsaw
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
	snd = HPF.ar(snd,40);
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

//theseanco's harpsi
SynthDef(\supersharpsi, {
    |out, freq, voice = 0.1, pan, sustain=1, att = 0.01, rel=1, synfb = 0.3, detune = 0|
    var snd, click=0, env;
    // Basic tone is a SinOsc
	
	env = EnvGen.ar(Env.linen(att,0.3,rel),timeScale:sustain,doneAction:2);
	env = EnvGen.ar(Env.linen(att,0.3,rel),timeScale:sustain,doneAction:2);
	snd = LFTri.ar(freq, click, 1) * SinOscFB.ar(freq*((detune/100)+1),synfb,1);
	snd = LeakDC.ar(snd) * env;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));

}).add;


//james mccartney via jeff
SynthDef(\superspno, { |out, pan, freq=440, sustain=1, lopprop = 6|
	var output, n = 8, max = 0.04, min = 0.01, delay, pitch, detune, hammer, amp = 1, env;
	var midifreq = freq.cpsmidi;
	hammer = Decay2.ar(Trig.ar(1, SampleDur.ir), 0.08, 0.04, LFNoise2.ar([2000,4000].asSpec.map(amp), 0.25));
	output = Mix.ar(Array.fill(3, { arg i;
			detune = #[-0.04, 0, 0.03].at(i);
			delay = (1/(midifreq + detune).midicps);
			CombL.ar(hammer, delay, delay, 60*amp)
		}) );

	env = EnvGen.ar(Env.perc(0.01,sustain, amp, -1), doneAction:2);
	output = HPF.ar(output,freq/2) * env;
	output = LPF.ar(output, Clip.kr(lopprop*freq, 0, 16000));
	OffsetOut.ar(out, DirtPan.ar(output, ~dirt.numChannels, pan, env));
}).add;

/* Retrieved from
http://sccode.org/1-5aD
Glockenspiel, xylophone, and tubularBell are all based on a very similar structure.
By nicolaariutti and edited by Zé Craum
http://sccode.org/1-5ay#c835
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef(\supersglk, {
	arg out, freq = 440, sustain = 1, pan = 0;
	var att1 = 0.0001;
	var rel1 = 6;
	var exciterRel = 0.05;
	var amp = 0.01;
	var env, env2, snd, exciter;

	env = Env.perc(att1, exciterRel, 0.25).kr;
	env2 = EnvGen.ar(Env.perc(att1, sustain*4, 1),1, doneAction: 2);
	exciter = WhiteNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // harmonics
			        [1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
		        	[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: sustain
	);




	snd = snd * amp;
	
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env2));
},
metadata: (
	credit: "http://sccode.org/1-5aD",
	category: \bells,
	tags: [\pitched]
	)
).add;

SynthDef(\superspbell, { arg out, singSwitch = 0, freq = 2434, sustain = 1, pan;
	var snd, input, first, freqScale, mallet, sing;
	var amp = 0.5, att1 = 0.001, env2;
	freqScale = freq / 2434;
	env2 = EnvGen.ar(Env.perc(att1, sustain*4, 1),1, doneAction: 2);



	// mallet
	mallet = LPF.ar(
		in: Impulse.ar(0) ! 2 * amp,
		freq: 10000 * freqScale
	);

	// sing
	sing = LPF.ar(
		in: {PinkNoise.ar * Integrator.kr(singSwitch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp} ! 2,
		freq: 2434 * freqScale
	);

	sing = sing + Dust.ar(0.1);
	sing = LPF.ar(sing, 10000 * freqScale);
	sing = sing * LFNoise1.kr(0.5).range(-45, -30).dbamp;

	// input = mallet + sing
	input = mallet + (singSwitch.clip(0, 1) * sing);

	// resonant filter bank
	snd = DynKlank.ar(
		specificationsArrayRef: `[
			// Array of filter frequencies
			[
				(first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
				first + LFNoise1.kr(0.5).range(1,3),
				LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
				LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
				LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
				LFNoise1.kr(2).range(8665, 8670),
				LFNoise1.kr(2).range(8704, 8709),
				LFNoise1.kr(2).range(8807, 8817),
				LFNoise1.kr(2).range(9570, 9607),
				LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
				LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
				LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
			],
			// Array of filter amplitudes
			[
				LFNoise1.kr(1).range(-10, -5).dbamp,
				LFNoise1.kr(1).range(-20, -10).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				LFNoise1.kr(1).range(-12, -6).dbamp,
				-20.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp,
				-10.dbamp,
				-20.dbamp,
				-20.dbamp,
				-25.dbamp
			],
			// Array of filter decay times
			[
				20 * freqScale.pow(0.2),
				20 * freqScale.pow(0.2),
				5,
				5,
				0.6,
				0.5,
				0.3,
				0.25,
				0.4,
				0.5,
				0.4,
				0.6
			] * freqScale.reciprocal.pow(0.5)
		],
		input: input,
		freqscale: freqScale,
		freqoffset: 0,
		decayscale: sustain
	);



	OffsetOut.ar(out, DirtPan.ar(Mix.ar(snd*env2), ~dirt.numChannels, pan, env2));
	
},
metadata: (
	credit: "by wondersluyter",
	category: \bells,
	tags: [\percussion, \bell, \prayer, \tibetan]
)
).add;

SynthDef(\supersprisset, {arg out, pan, freq = 440, sustain = 1, pulseFreq = 8;
    var partials, durs, amps, snd, env;
	var att = 0.01, rel = 11, amp = 0.1;
 	partials = [246.4, 247.4, 404.8, 406.5, 523.6, 748, 880, 1206, 1320, 1654, 1791]; // original freqs
	partials = (partials / 440) * freq; // consider 440 the 'root'
	durs = [11, 10, 7, 6, 4, 3.4, 3, 2.2, 2, 1.1, 1] / 11;
	amps = durs.linlin(1, 11, 0.2, 1);

	env = Env.perc(
		attackTime: att,
		releaseTime: durs * rel * sustain,
		level: amps
	).kr(doneAction: [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]); // only longest env gets doneAction: 2

	snd = Pulse.ar(partials) * env * amp / 11;

	snd = RLPF.ar(
		in: snd,
		freq: freq * LFPulse.ar(pulseFreq).range(2, 4),
		rq: SinOsc.ar(LFNoise2.kr(1).range(4, 9)).range(0.1, 0.3));

	snd = LPF.ar(snd, 12000);
	snd = Limiter.ar(Mix.ar(snd));

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));

},
metadata: (
	credit: "by Bruno Tucunduva Ruviaro, based on Jean-Claude Risset's bell",
	category: \bells,
	tags: [\percussion, \bell, \inharmonic]
)
).add;

SynthDef(\supersrbell, { arg out, pan, freq = 400, sustain = 1;
	var amp  = 0.1;
	var att = 0.005;
	var amps = #[1, 0.67, 1, 1.8, 2.67, 1.67, 1.46, 1.33, 1.33, 1, 1.33];
	var durs = #[1, 0.9, 0.65, 0.55, 0.325, 0.35, 0.25, 0.2, 0.15, 0.1, 0.075];
	var frqs = #[0.56, 0.56, 0.92, 0.92, 1.19, 1.7, 2, 2.74, 3, 3.76, 4.07];
	var dets = #[0, 1, 0, 1.7, 0, 0, 0, 0, 0, 0, 0];

	var env2 = EnvGen.ar(Env.perc(0.005, att+sustain*2, 1), 1, doneAction: 2);
	var snd = Mix.fill(11, {arg i;
		var env = EnvGen.ar(Env.perc(
			attackTime: att,
			releaseTime: sustain*2 * durs[i],
			level: amps[i],
			curve: att.explin(0.005, 4, -4.5, 0)
		), 1);
		SinOsc.ar(
			freq: freq * frqs[i] + dets[i],
			mul: amp * env
		);
	});
	snd = snd * env2 * 0.5;
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env2));

},
metadata: (
	credit: "based on Jean-Claude Risset's bell",
	category: \bells,
	tags: [\percussion, \bell, \inharmonic]
)
).add;


SynthDef(\superssosbell, {
	arg
	//Standard Values
	freq = 440, out, sustain = 1,pan;
	var 
	//ring Controls (wobbleDepth goes from 0 to 1)
	ringAmp = 1, ringRel = 0.9, wobbleDepth = 0.6, wobbleMin = 1, wobbleMax = 1.8,
	//strike Controls
	strikeAmp = 1, strikeDec = 0.01, strikeRel = 0.04, strikeDepth = 0.028, strikeHarmonic = 8,
	//hum Controls
	humAmp = 0.5, humAtt = 0.5, humDec = 0.5, humRel = 1;

	var amp = 0.1, curve = \lin, rel = sustain*2, env;
	var snd, ring, ringEnv, ringFreqs, strike, strikeEnv, strikeMod, hum, humEnv;

	env = EnvGen.ar(Env.perc(0.001, rel),1,doneAction:2);
	ringFreqs = [2, 3, 4.1, 5.43, 6.8, 8.21];

	ringEnv = Env.new(
		            levels: [1, 0.3, 0.2, 0],
		            times: [1/3, 1/3, 1/3] * ringRel * rel,
		            curve: curve).kr;

	ring = SinOsc.ar(
		            freq: ringFreqs * freq,
		            mul: Array.series(6, 1, -0.1) * ringEnv);

	ring = ring * LFTri.ar(
		            freq: {Rand(wobbleMin, wobbleMax)}.dup(6)).range((1 - wobbleDepth), 1);

	strikeEnv = Env.new(
		            levels: [1, 0.1, 0],
		            times: [strikeDec, strikeRel * rel],
		            curve: curve).kr;

	strikeMod = LFNoise1.ar(freq * 36).range(1/ (strikeDepth + 1), strikeDepth + 1);

	strike = SinOsc.ar(
                    freq: freq * strikeHarmonic * strikeMod,
		            mul: strikeEnv);

	humEnv = Env.new(
		            levels: [0, 1, 0.8, 0],
		            times: [humAtt, humDec, humRel * rel],
		            curve: curve).kr;

	hum = SinOsc.ar(
		            freq: freq * [1.01, 0.47],
		            mul: humEnv);

	snd = Mix.ar((ring * ringAmp) + (strike * strikeAmp) + (hum * humAmp)) * amp;

	OffsetOut.ar(out, DirtPan.ar(snd*env, ~dirt.numChannels, pan, env));


},
metadata: (
	credit: "dan stowell",
	category: \bells,
	tags: [\bell, \percussion, \pitched, \additive, \sos]
	)
).add;

/* Retrieved from
http://sccode.org/1-5aD
Glockenspiel, xylophone, and tubularBell are all based on a very similar structure.
By nicolaariutti and edited by Zé Craum
http://sccode.org/1-5ay#c835
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef(\superschimes, {
	arg freq = 440, pan, sustain = 1, out;

	var amp = 0.1, att = 0.005, rel = 9 * sustain, exciterRel = 0.05, env2; 
	var env, snd, exciter;

	env = Env.perc(att, exciterRel, 0.05).kr;
	env2 = EnvGen.ar(Env.perc(att, rel), 1, doneAction: 2);
	exciter = GrayNoise.ar(env);

	snd = DynKlank.ar(
		specificationsArrayRef:
	        	Ref.new([
	        		[1.013, 1.512, 2.113, 2.525, 3.35, 4.57, 6.48],   // harmonics
			        [1, 0.78, 0.89, 0.63, 0.31, 0.56, 0.25], // amplitudes
		        	[1, 0.9, 0.8, 0.65, 0.45, 0.3, 0.1]     // ring times
		        ]),
		input: exciter,
		freqscale: freq,
		decayscale: rel
	);

	snd = LPF.ar(snd, freq * 9.5);



	OffsetOut.ar(out, DirtPan.ar(snd*env2, ~dirt.numChannels, pan, env));

},
metadata: (
	credit: "nicolaariutti, Zé Craum, Josh Mitchell",
	category: \bells,
	tags: [\pitched, \tubular, \bell]
	)
).add;


/* Retrieved from
http://sccode.org/1-5aD
Harpsichord based on Pluck Ugen
Original by Zé Craum
Modified by Bruno Ruviaro and Josh Mitchell 8/19.
*/

SynthDef(\supersharpsi2, {
	arg
	//Standard Values
	out,freq = 440, pan, sustain = 1;
	//Pluck arguments (blend goes from 0 to 1)
	var trig = 1, decaytime = sustain*7, coef = 0.1, blend = 0.6;
	var att = 0.001, amp = 1;
	var env, exciter, root, octave, snd;


	env = EnvGen.ar(Env.perc(att, decaytime), 1, doneAction: 2);
	exciter = PinkNoise.ar(amp); //Can use white noise here, but Pink is more realistic

    root = Pluck.ar(  //fundamental
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 0.06, //only change this if freq goes below 20hz
	        delaytime: 1 / freq,
	        decaytime: decaytime,
	        coef: coef,
	        mul: blend
        );

	octave = Pluck.ar(  //octave up
	        in: exciter,
	        trig: trig,
	        maxdelaytime: 0.06, //only change this if freq goes below 20hz
	        delaytime: 1 / (2 * freq),
	        decaytime: decaytime,
	        coef: coef,
	        mul: (1 - blend)
        );

	snd = Mix.ar(root + octave);
	
	OffsetOut.ar(out, DirtPan.ar(snd*env, ~dirt.numChannels, pan, env));

},
metadata: (
	credit: "Zé Craum",
	category: \keyboards,
	tags: [\pitched]
	)
).add;

//from sclorkugens
SynthDef(\superssaw, {
	arg freq = 440, sustain = 1, pan, out, lofreq = 1000, hifreq = 3000;
    var env, snd, amp = 0.1, rel = sustain*2, att = 0.1;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp
	).kr(doneAction: 2);
    snd = Saw.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));

// Basic saw synth for chords and bass
//By Bruno Ruviaro
//http://sccode.org/1-54H
}).add;


//from sclorkugens

SynthDef(\superswarsaw, {
	arg
	//Standard Values:
	out = 0, freq = 440, pan, dec = 0.3, sustain = 1;
	var amp = 0.5,
	//Other Controls:
	slideTime = 0.17, cutoff = 1100, width = 0.15, detune = 1.005, preamp = 4;

	var snd, env;
	env = EnvGen.ar(Env.pairs([[0,0],[0.05,1],[0.2,1-dec],[0.95,1-dec],[1,0]], -3), timeScale:sustain, doneAction:2);
	
	freq = Lag.kr(freq, slideTime);
	snd = VarSaw.ar(freq: [freq, freq * detune], width: width, mul: preamp);
	snd = Mix(snd).distort;
	snd = snd * env;
	snd = LPF.ar(snd, cutoff, amp);

	OffsetOut.ar(out, DirtPan.ar(snd, ~dirt.numChannels, pan, env));

},
metadata: (
	credit: "James Harkins",
	category: \bass,
	tags: [\bass, \synth, \pitched]
	)
).add;



/*
//based on john bower's modal freqs

SynthDef(\superswood, {|out, pan, freq = 100, pitchy = 0.75,sustain = 1 |
	var freqs = [1, 2.572, 4.644, 6.984, 9.823, 12];
	var amps = [1, 1, 0.75, 0.75, 0.5, 0.1, 0.1] * freqs.size.reciprocal;
	var rings = [0.1, 0.01, 0.01, 0.05, 0.01, 0.01];
	var exciter = Trig.ar(1, 64/SampleRate.ir);
	var output = Klank.ar(`[freqs, amps, rings], exciter, freq,0,pitchy*sustain);
	output = Pan2.ar(output, pan);
	DetectSilence.ar(output, doneAction: 2);
	Out.ar(out, output);
}).add;

//doesn't sound good at low freqs
SynthDef(\dxkWineBank, {|out, pan, freq = 1000, pitchy = 1, sustain = 1|
	var freqs = [1, 2.32, 4.25, 6.63, 9.38];
	var amps = [1, 0.6, 0.4, 0.2, 0.1] * freqs.size.reciprocal;
	var rings = [1, 0.8, 0.6, 0.4, 0.4];
	var exciter = Trig.ar(t_trig, 64/SampleRate.ir);
	var output = Klank.ar(`[freqs, amps, rings], exciter, freq, 0, pitchy*sustain);
	output = Pan2.ar(output, pan);
	DetectSilence.ar(output, doneAction: 2);
	Out.ar(out, output);
}).add;
*/
