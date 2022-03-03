:set -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Context

import System.IO (hSetEncoding, stdout, utf8)

hSetEncoding stdout utf8

-- arduinoRouter = OSCTarget {oName = "arduinoRouter", oAddress = "127.0.0.1", oPort = 5050, oPath = "/tidal", oShape = Nothing, oLatency = 0.02, oPreamble = [], oTimestamp = BundleStamp}

-- total latency = oLatency + cFrameTimespan

tidal <- startTidal (superdirtTarget {oLatency = 0.37, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/10})

-- midi input
-- tidal <- startTidal (superdirtTarget {oLatency = 0.3, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/15, cCtrlAddr = "127.0.0.1", cCtrlPort = 6010})

-- tidal <- startMulti [(superdirtTarget {oLatency = 0.2, oAddress = "127.0.0.1", oPort = 57120}), arduinoRouter] (defaultConfig {cFrameTimespan = 1/20})

{-tidal <- startMulti [superdirtTarget {oLatency = 0.25, oAddress = "127.0.0.1", oPort = 57120}, p5Target] (defaultConfig {cFrameTimespan = 1/20}) -}

:{
let only = (hush >>)
    p = streamReplace tidal
    hush = streamHush tidal
    list = streamList tidal
    mute = streamMute tidal
    unmute = streamUnmute tidal
    solo = streamSolo tidal
    unsolo = streamUnsolo tidal
    once = streamOnce tidal
    first = streamFirst tidal
    asap = once
    nudgeAll = streamNudgeAll tidal
    all = streamAll tidal
    resetCycles = streamResetCycles tidal
    setcps = asap . cps
    xfade i = transition tidal True (Sound.Tidal.Transition.xfadeIn 4) i
    xfadeIn i t = transition tidal True (Sound.Tidal.Transition.xfadeIn t) i
    histpan i t = transition tidal True (Sound.Tidal.Transition.histpan t) i
    wait i t = transition tidal True (Sound.Tidal.Transition.wait t) i
    waitT i f t = transition tidal True (Sound.Tidal.Transition.waitT f t) i
    jump i = transition tidal True (Sound.Tidal.Transition.jump) i
    jumpIn i t = transition tidal True (Sound.Tidal.Transition.jumpIn t) i
    jumpIn' i t = transition tidal True (Sound.Tidal.Transition.jumpIn' t) i
    jumpMod i t = transition tidal True (Sound.Tidal.Transition.jumpMod t) i
    mortal i lifespan release = transition tidal True (Sound.Tidal.Transition.mortal lifespan release) i
    interpolate i = transition tidal True (Sound.Tidal.Transition.interpolate) i
    interpolateIn i t = transition tidal True (Sound.Tidal.Transition.interpolateIn t) i
    clutch i = transition tidal True (Sound.Tidal.Transition.clutch) i
    clutchIn i t = transition tidal True (Sound.Tidal.Transition.clutchIn t) i
    anticipate i = transition tidal True (Sound.Tidal.Transition.anticipate) i
    anticipateIn i t = transition tidal True (Sound.Tidal.Transition.anticipateIn t) i
    forId i t = transition tidal False (Sound.Tidal.Transition.mortalOverlay t) i
    d1 = p 1 . (|< orbit 0) 
    d2 = p 2 . (|< orbit 1) 
    d3 = p 3 . (|< orbit 2) 
    d4 = p 4 . (|< orbit 3) 
    d5 = p 5 . (|< orbit 4) 
    d6 = p 6 . (|< orbit 5) 
    d7 = p 7 . (|< orbit 6) 
    d8 = p 8 . (|< orbit 7) 
    d9 = p 9 . (|< orbit 8)
    d10 = p 10 . (|< orbit 9)
    d11 = p 11 . (|< orbit 10)
    d12 = p 12 . (|< orbit 11)
    d13 = p 13
    d14 = p 14
    d15 = p 15
    d16 = p 16
:}

:{
let getState = streamGet tidal
    setI = streamSetI tidal
    setF = streamSetF tidal
    setS = streamSetS tidal
    setR = streamSetR tidal
    setB = streamSetB tidal
:}


:{
let duty = pF "duty"
    lopprop = pF "lopprop"
    pmfreq = pF "pmfreq"
    pmidx = pF "pmidx"
    midx = pF "midx"
    mharm = pF "mharm"
    target = pF "target"
    synFb = pF "synFb"
    detune = pF "detune"
    lofreq = pF "lofreq"
    hifreq = pF "hifreq"
    singSwitch = pF "singSwitch"
    synCutoff = pF "synCutoff"
    synChorus = pF "synChorus"
    lfo = pF "lfo"
    lfoWidth = pF "lfoWidth"
    synRq = pF "synRq"
    winSize = pF "winSize"
    pDisp = pF "pDisp"
    tDisp = pF "tDisp"
    pRatio = pF "pRatio"
    pLag = pF "pLag"
    ampThresh = pF "ampThresh"
    clean = pF "clean"
    tracked = pF "tracked"
:}


:{
let ahr x y z = (att x # hold y # rel z)
    rsd x y z = (room x # size y # dry z)
    deltf x y z = (delay x # delaytime y # delayfb z)
    fmod x y = (mharm x # midx y)
    pmod x y= (pmfreq x # pmidx y)
    edo x y = note (toScale (map (* (12/x)) [0 .. (x-1)]) y)
    phasrd x y = (phasr x # phasdp y)
    lrs x y z = (leslie x # lrate y # lsize z)
    rfs x y z = (ring x # ringf y # ringdf z)
    silencer y = do
        mapM_ (\x -> p x silence) y
    :}


-- let dlopamp = pF "dlopamp"; dlopfb = pF "dlopfb"; dlopt = pF "dlopt"; dloplpf = pF "dloplpf"; dloplock = pF "dloplock"; fvbdry = pF "fvbdry"; fvbrm = pF "fvbrm"; fvbsize = pF "fvbsize"; fvbdamp = pF "fvbdamp"; fvblpfin = pF "fvblpfin"; fvblpfout= pF "fvblpfout"


:set prompt "tidal> "

default (Pattern String, Integer, Double)
