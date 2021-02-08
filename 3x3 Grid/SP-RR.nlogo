breed [cars car]
breed [traffic-lights traffic-light]

;; direction is one of 0, 90, 180, 270
cars-own [speed acceleration direction source destination start-time]

patches-own
[
  sidewalk? crosswalk? track? intersection? intersection-1? intersection-2? intersection-3? intersection-4? intersection-5? intersection-6? intersection-7? intersection-8?
  sensor0? sensor1? sensor2? sensor3? sensor4? sensor5? sensor6? sensor7? sensor8? from change-marker
]

globals
[
  gen-freq max-speed
  car-length
  road-color sidewalk-color lane-divider-color crosswalk-color

  round-robin-state
  round-robin-last
  tick-count-last

  max-wait-time-cars
  min-wait-time-cars
  total-wait-time-cars
  average-wait-time-cars
  total-cars

  count-carNS
  count-carEW

  count-carEWpass
  count-carNSpass
  count-carenter

  count-carEWwait
  count-carNSwait
  green-light-durationEW
  green-light-durationEWcheck
  green-light-durationNS
  rate
  rate-carEW
  rate-carNS
]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  setup-globals
  setup-patches
  setup-agents
  setup-traffic-lights
  plot-data
end

to setup-globals

  set gen-freq 10
  set max-speed 2

  set car-length 10

  set road-color 3             ;; dark gray
  set lane-divider-color 46    ;; light yellow
  set sidewalk-color 8         ;; light gray
  set crosswalk-color 9.5      ;; off-white

  set round-robin-state 2
  set round-robin-last "NS"
  set tick-count-last 0

  set max-wait-time-cars 0
  set min-wait-time-cars 0

  set total-wait-time-cars 0
  set average-wait-time-cars 0
  set total-cars 0

end



to setup-patches
  ask patches
  [
    set pcolor 3
    set intersection? false
    set intersection-1? false
    set intersection-2? false
    set intersection-3? false
    set intersection-4? false
    set intersection-5? false
    set intersection-6? false
    set intersection-7? false
    set intersection-8? false

    set track? false
    set sensor0? false
    set sensor1? false
    set sensor2? false
    set sensor3? false
    set sensor4? false
    set sensor5? false
    set sensor6? false
    set sensor7? false
    set sensor8? false

    set change-marker 0

    ;; road
    if (pycor >= -10 and pycor <= 10) or
    (pxcor >= -10 and pxcor <= 10)
    [
      set pcolor road-color
    ]

    ; intersection 0
    if (pycor >= -10 and pycor <= 10) and
    (pxcor >= -10 and pxcor <= 10)
    [
      set intersection? true
      set pcolor road-color
    ]

    ; intersection 1
    if (pycor >= -10 and pycor <= 10) and
    (pxcor >= -160 and pxcor <= -140)
    [
      set intersection-1? true
      set pcolor road-color
    ]

    ; intersection 2
    if (pycor >= 130 and pycor <= 150) and
    (pxcor >= -160 and pxcor <= -140)
    [
      set intersection-2? true
      set pcolor road-color
    ]

    ; intersection 3
    if (pycor >= 130 and pycor <= 150) and
    (pxcor >= -10 and pxcor <= 10)
    [
      set intersection-3? true
      set pcolor road-color
    ]

    ; intersection 4
    if (pycor >= 130 and pycor <= 150) and
    (pxcor >= 140 and pxcor <= 160)
    [
      set intersection-4? true
      set pcolor road-color
    ]

    ; intersection 5
    if (pycor >= -10 and pycor <= 10) and
    (pxcor >= 140 and pxcor <= 160)
    [
      set intersection-5? true
      set pcolor road-color
    ]

    ; intersection 6
    if (pycor >= -150 and pycor <= -130) and
    (pxcor >= 140 and pxcor <= 160)
    [
      set intersection-6? true
      set pcolor road-color
    ]

    ; intersection 7
    if (pycor >= -150 and pycor <= -130) and
    (pxcor >= -10 and pxcor <= 10)
    [
      set intersection-7? true
      set pcolor road-color
    ]

    ; intersection 8
    if (pycor >= -150 and pycor <= -130) and
    (pxcor >= -160 and pxcor <= -140)
    [
      set intersection-8? true
      set pcolor road-color
    ]

    ;; crosswalk
    if ((pxcor >  10 and pxcor <=  15) and (pycor >= -10 and pycor <= 10)) or
    ((pxcor < -10 and pxcor >= -15) and (pycor >= -10 and pycor <= 10)) or
    ((pycor >  10 and pycor <=  15) and (pxcor >= -10 and pxcor <= 10)) or
    ((pycor < -10 and pycor >= -15) and (pxcor >= -10 and pxcor <= 10))
    [
      set crosswalk? true
    ]

    ;; crosswalk lines
    ; intersection 0 (middle)
    if ((pxcor =  10 or pxcor =  15) and (pycor >= -10 and pycor <= 10)) or
    ((pxcor = -10 or pxcor = -15) and (pycor >= -10 and pycor <= 10)) or
    ((pycor =  10 or pycor =  15) and (pxcor >= -10 and pxcor <= 10)) or
    ((pycor = -10 or pycor = -15) and (pxcor >= -10 and pxcor <= 10))
    [
      set pcolor crosswalk-color
    ]

    ; intersection 1
    if ((pxcor =  -160 or pxcor =  -165) and (pycor >= -10 and pycor <= 10)) or
    ((pxcor = -140 or pxcor = -135) and (pycor >= -10 and pycor <= 10)) or
    ((pycor =  10 or pycor =  15) and (pxcor >= -160 and pxcor <= -140)) or
    ((pycor = -10 or pycor = -15) and (pxcor >= -160 and pxcor <= -140))
    [
      set pcolor crosswalk-color
    ]

    ; intersection 3
    if
    ((pxcor =  10 or pxcor =  15) and (pycor >= 130 and pycor <= 150)) or
    ((pxcor = -10 or pxcor = -15) and (pycor >= 130 and pycor <= 150)) or
    ((pycor = 150 or pycor = 155) and (pxcor >= -10 and pxcor <= 10)) or
    ((pycor = 130 or pycor = 125) and (pxcor >= -10 and pxcor <= 10))
    [
      set pcolor crosswalk-color
    ]

    ; intersection 4
    if
    ((pxcor = 160 or pxcor = 165) and (pycor >= 130 and pycor <= 150)) or
    ((pxcor = 140 or pxcor = 135) and (pycor >= 130 and pycor <= 150)) or
    ((pycor = 150 or pycor = 155) and (pxcor >= 160 and pxcor <= 140)) or
    ((pycor = 130 or pycor = 125) and (pxcor >= 160 and pxcor <= 140))
    [
      set pcolor crosswalk-color
    ]

    ; intersection 5
    if
    ((pxcor = 160 or pxcor = 165) and (pycor >= -10 and pycor <= 10)) or
    ((pxcor = 140 or pxcor = 135) and (pycor >= -10 and pycor <= 10)) or
    ((pycor = 150 or pycor = 155) and (pxcor >= 160 and pxcor <= 140)) or
    ((pycor = 130 or pycor = 125) and (pxcor >= 160 and pxcor <= 140))
    [
      set pcolor crosswalk-color
    ]

    ; intersection 7
    if
    ((pxcor =  10 or pxcor =  15) and (pycor >= -150 and pycor <= -130)) or
    ((pxcor = -10 or pxcor = -15) and (pycor >= -150 and pycor <= -130)) or
    ((pycor = -150 or pycor = -155) and (pxcor >= -10 and pxcor <= 10)) or
    ((pycor = -130 or pycor = -125) and (pxcor >= -10 and pxcor <= 10))
    [
      set pcolor crosswalk-color
    ]

    ; sidewalk
    if
    ((pxcor >  10 and pxcor <=  15) and (pycor < -10 or pycor > 10)) or
    ((pxcor < -10 and pxcor >= -15) and (pycor < -10 or pycor > 10)) or

    ((pxcor <  -135 and pxcor >= -140) and (pycor < -10 or pycor > 10)) or
    ((pxcor < -160 and pxcor >= -165) and (pycor < -10 or pycor > 10)) or

    ((pycor >  10 and pycor <=  15) and (pxcor < -10 or pxcor > 10)) or
    ((pycor < -10 and pycor >= -15) and (pxcor < -10 or pxcor > 10)) or

    ((pxcor >  135 and pxcor  <= 140) and (pycor < -10 or pycor > 10)) or
    ((pxcor > 160 and pxcor <= 165) and (pycor < -10 or pycor > 10)) or

    ((pycor > -130 and pycor <= -125) and (pxcor < -10 or pxcor > 10)) or
    ((pycor > -155 and pycor <= -150) and (pxcor < -10 or pxcor > 10)) or

    ((pycor > 125 and pycor <= 130) and (pxcor < -10 or pxcor > 10)) or
    ((pycor > 150 and pycor <= 155) and (pxcor < -10 or pxcor > 10))
    [
      set sidewalk? true
      set pcolor sidewalk-color
    ]

    ;; sensors
    ; intersection 0
    if (pxcor < -15 and pxcor >= -20) and (pycor <   0 and pycor >= -10) [set sensor0? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor <   0 and pxcor >= -10) and (pycor >  15 and pycor <=  20) [set sensor0? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor >  15 and pxcor <=  20) and (pycor >   0 and pycor <=  10) [set sensor0? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor >   0 and pxcor <=  10) and (pycor < -15 and pycor >= -20) [set sensor0? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 1
    if (pxcor < -165 and pxcor >= -170) and (pycor <   0 and pycor >= -10) [set sensor1? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < -150 and pxcor >= -160) and (pycor >  15 and pycor <=  20) [set sensor1? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -135 and pxcor <= -130) and (pycor >   0 and pycor <=  10) [set sensor1? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -150 and pxcor <= -140) and (pycor < -15 and pycor >= -20) [set sensor1? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 2
    if (pxcor < -165 and pxcor >= -170) and (pycor < 140 and pycor >= 130) [set sensor2? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < -150 and pxcor >= -160) and (pycor > 155 and pycor <= 160) [set sensor2? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -135 and pxcor <= -130) and (pycor > 140 and pycor <= 150) [set sensor2? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -150 and pxcor <= -140) and (pycor < 125 and pycor >= 120) [set sensor2? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 3
    if (pxcor < -15 and pxcor >= -20) and (pycor < 140 and pycor >= 130) [set sensor3? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor <   0 and pxcor >= -10) and (pycor > 155 and pycor <= 160) [set sensor3? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor >  15 and pxcor <=  20) and (pycor > 140 and pycor <= 150) [set sensor3? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor >   0 and pxcor <=  10) and (pycor < 125 and pycor >= 120) [set sensor3? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 4
    if (pxcor < 135 and pxcor >= 130) and (pycor < 140 and pycor >= 130) [set sensor4? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < 150 and pxcor >= 140) and (pycor > 155 and pycor <= 160) [set sensor4? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 165 and pxcor <= 170) and (pycor > 140 and pycor <= 150) [set sensor4? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 150 and pxcor <= 160) and (pycor < 125 and pycor >= 120) [set sensor4? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 5
    if (pxcor < 135 and pxcor >= 130) and (pycor < 0 and pycor >= -10) [set sensor5? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < 150 and pxcor >= 140) and (pycor > 15 and pycor <= 20) [set sensor5? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 165 and pxcor <= 170) and (pycor > 0 and pycor <= 10) [set sensor5? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 150 and pxcor <= 160) and (pycor < -15 and pycor >= -20) [set sensor5? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 6
    if (pxcor < 135 and pxcor >= 130) and (pycor < -140 and pycor >= -150) [set sensor6? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < 150 and pxcor >= 140) and (pycor > -125 and pycor <= -120) [set sensor6? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 165 and pxcor <= 170) and (pycor > -140 and pycor <= -130) [set sensor6? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 150 and pxcor <= 160) and (pycor < -155 and pycor >= -160) [set sensor6? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 7
    if (pxcor < -15 and pxcor >= -20) and (pycor < -140 and pycor >= -150) [set sensor7? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < 0 and pxcor >= -10) and (pycor > -125 and pycor <= -120) [set sensor7? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 15 and pxcor <= 20) and (pycor > -140 and pycor <= -130) [set sensor7? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > 0 and pxcor <= 10) and (pycor < -155 and pycor >= -160) [set sensor7? true set from   0 if show-sensors? [set pcolor 135]] ;;pink

    ; intersection 8
    if (pxcor < -165 and pxcor >= -170) and (pycor < -140 and pycor >= -150) [set sensor7? true set from  90 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor < -150 and pxcor >= -160) and (pycor > -125 and pycor <= -120) [set sensor7? true set from 180 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -135 and pxcor <= -130) and (pycor > -140 and pycor <= -130) [set sensor7? true set from 270 if show-sensors? [set pcolor 135]] ;;pink
    if (pxcor > -150 and pxcor <= -140) and (pycor < -155 and pycor >= -160) [set sensor7? true set from   0 if show-sensors? [set pcolor 135]] ;;pink
  ]

  ;; lane-dividers (do this for the entire patch set, not each patch)
  paint-stripes  0  0  1  0 max-pxcor 1         lane-divider-color 5
  paint-stripes 0   0 -1  0 min-pxcor 1         lane-divider-color 5
  paint-stripes   0  0  0  1 1         max-pycor lane-divider-color 5
  paint-stripes   0 0  0 -1 1         min-pycor lane-divider-color 5


  paint-stripes  0  140  1  0 max-pxcor max-pycor        lane-divider-color 5
  paint-stripes  0  -140  1  0 max-pxcor max-pycor        lane-divider-color 5
  paint-stripes  0  140  -1  0 max-pxcor max-pycor        lane-divider-color 5
  paint-stripes  0  -140  -1  0 max-pxcor max-pycor        lane-divider-color 5


  paint-stripes   150  0  0  1 max-pxcor   max-pycor lane-divider-color 5
  paint-stripes    150  0  0 -1 max-pxcor    min-pycor lane-divider-color 5

  paint-stripes   -150  0  0  1 max-pxcor   max-pycor lane-divider-color 5
  paint-stripes    -150  0  0 -1 max-pxcor    min-pycor lane-divider-color 5

  ;; ties (do this for the entire patch set, not each patch)
  let index min-pxcor
  let width 2
  let len 9
  let step 5

  while [index <= max-pxcor]
  [
    let w 0
    while [w < width]
    [
      let l 0
      while [l < len and (index + w <= max-pxcor)]
      [
        ;  ask patch (index + w) (61 + l) [set pcolor tie-color]
        set l (l + 1)
      ]
      set w (w + 1)
    ]
    set index (index + step)
  ]

end

to paint-stripes [x-start y-start x-incr y-incr x-max y-max col len]

  let on? true
  let patch-count 0
  let x x-start
  let y y-start

  while [abs x <= abs x-max and abs y <= abs y-max]
  [
    if patch-count mod len = 0 [set on? (not on?)]
    ask patch x y
    [
      if on? [set pcolor col]
    ]

    set x (x + x-incr)
    set y (y + y-incr)
    set patch-count (patch-count + 1)
  ]

end

to setup-agents
  ;; cars
  set-default-shape cars "car"
end

to setup-traffic-lights
  foreach [0 180]         [ ?1 -> set-car-light ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light1 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light1 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light2 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light2 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light3 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light3 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light4 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light4 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light5 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light5 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light6 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light6 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light7 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light7 ?1 red ]

  foreach [0 180]         [ ?1 -> set-car-light8 ?1 green ]
  foreach [90 270]        [ ?1 -> set-car-light8 ?1 red ]
end

to set-car-light [dir col]
  ask patches with [sensor0? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light1 [dir col]
  ask patches with [sensor1? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light2 [dir col]
  ask patches with [sensor2? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light3 [dir col]
  ask patches with [sensor3? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light4 [dir col]
  ask patches with [sensor4? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light5 [dir col]
  ask patches with [sensor5? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light6 [dir col]
  ask patches with [sensor6? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light7 [dir col]
  ask patches with [sensor7? = true and from = dir] [set pcolor col set change-marker ticks]
end

to set-car-light8 [dir col]
  ask patches with [sensor8? = true and from = dir] [set pcolor col set change-marker ticks]
end

;; runtime
to go
  manage-traffic-light
  ;; move-cars
  gen-cars
  tick
  if ticks >= 1000 [stop]
  ;if total-cars >= 20 [stop]
  ;if total-pedestrians >= 10 [stop]
  plot-data
end

to manage-traffic-light
  if scheduling-algorithm = "SP-RR" [manage-traffic-light-RR]
end

to manage-traffic-light-RR
  if (green-light-durationEW = green-light-durationNS)
  [
    ;; simple round robin
    if (round-robin-last = "NS")
    [
      if (ticks - tick-count-last = green-light-duration)
      [
        foreach [90 270] [ ?1 -> set-car-light ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light1 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light1 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light2 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light2 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light3 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light3 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light4 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light4 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light5 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light5 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light6 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light6 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light7 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light7 ?1 red ]

        foreach [90 270] [ ?1 -> set-car-light8 ?1 green ]
        foreach [0 180] [ ?1 -> set-car-light8 ?1 red ]

        let next-dir "EW"
        set tick-count-last ticks
        set round-robin-last next-dir
      ]
    ]
    if (round-robin-last = "EW")
    [
      if (ticks - tick-count-last = green-light-duration)
      [
        foreach [90 270] [ ?1 -> set-car-light ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light1 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light1 ?1 green ]


        foreach [90 270] [ ?1 -> set-car-light2 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light2 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light3 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light3 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light4 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light4 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light5 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light5 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light6 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light6 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light7 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light7 ?1 green ]

        foreach [90 270] [ ?1 -> set-car-light8 ?1 red ]
        foreach [0 180] [ ?1 -> set-car-light8 ?1 green ]

        let next-dir "NS"
        set tick-count-last ticks
        set round-robin-last next-dir
      ]
    ]
  ]
end


to-report free-space [x y dir]

  let dist 0
  let max-dist (car-length + 1)
  let x-delta 0
  let y-delta 0

  if dir = 0   [ set y-delta 1 ]
  if dir = 90  [ set x-delta 1 ]
  if dir = 180 [ set y-delta -1 ]
  if dir = 270 [ set x-delta -1 ]

  while [dist <= max-dist]
  [
    let next-patch patch x y
    if next-patch != nobody
    [
      let car-ahead one-of turtles-on next-patch
      if car-ahead != nobody and is-car? car-ahead
      [
        report false
      ]
    ]
    set x (x + x-delta)
    set y (y + y-delta)
    set dist (dist + 1)
  ]
  report true
end

to gen-cars

  if (ticks mod gen-freq = 0)
  [
    ;; Show ticks
    foreach [0 90 180 270]
    [ ?1 ->
      let free-space? false;

      let x 0
      let y 0

      if ?1 = 0 and (random 100 < LS-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x -145
        set y min-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 0 and (random 100 < MS-car-density)
      [
        set count-carNS (count-carNS + 1)
        set x 5
        set y min-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 0 and (random 100 < RS-car-density)
      [
        set count-carNS (count-carNS + 1)
        set x 155
        set y min-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]


      if ?1 = 90 and (random 100 < TW-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x min-pxcor
        set y 135
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 90 and (random 100 < MW-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x min-pxcor
        set y -5
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 90 and (random 100 < DW-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x min-pxcor
        set y -145
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]


      if ?1 = 180 and (random 100 < LN-car-density)
      [
        set count-carNS (count-carNS + 1)
        set x -155
        set y max-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 180 and (random 100 < MN-car-density)
      [
        set count-carNS (count-carNS + 1)
        set x -5
        set y max-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 180 and (random 100 < RN-car-density)
      [
        set count-carNS (count-carNS + 1)
        set x 145
        set y max-pycor
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]

      if ?1 = 270 and (random 100 < TE-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x max-pxcor
        set y 145
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 270 and (random 100 < ME-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x max-pxcor
        set y 5
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]
      if ?1 = 270 and (random 100 < DE-car-density)
      [
        set count-carEW (count-carEW + 1)
        set x max-pxcor
        set y -135
        set free-space? (free-space x y ?1)
        set count-carenter(count-carenter + 1)
      ]

      ;; TODO: decision here, or make it configurable? : only generate a car if there's room,
      ;;   or let them stack up
      ;; if (x != 0) prevents the generation of cars when the randomization
      ;; above does not yield one :)
      if (x != 0) ;; and free-space?
      [
        ask patch x y
        [
          sprout-cars 1
          [
            ;; pass in the current direction of the foreach loop
            init-car ?1
          ]
        ]
      ]
    ]
  ]

  ;; move-cars
  ask cars
  [
    ifelse can-move? speed
    [
      check-ahead-and-react

      ; sensor0
      let on-sensor0? false
      ask patch-here [if sensor0? [set on-sensor0? true]]
      if on-sensor0?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor1
      let on-sensor1? false
      ask patch-here [if sensor1? [set on-sensor1? true]]
      if on-sensor1?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor2
      let on-sensor2? false
      ask patch-here [if sensor2? [set on-sensor2? true]]
      if on-sensor2?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor3
      let on-sensor3? false
      ask patch-here [if sensor3? [set on-sensor3? true]]
      if on-sensor3?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor4
      let on-sensor4? false
      ask patch-here [if sensor4? [set on-sensor4? true]]
      if on-sensor4?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor5
      let on-sensor5? false
      ask patch-here [if sensor5? [set on-sensor5? true]]
      if on-sensor5?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor6
      let on-sensor6? false
      ask patch-here [if sensor6? [set on-sensor6? true]]
      if on-sensor6?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor7
      let on-sensor7? false
      ask patch-here [if sensor7? [set on-sensor7? true]]
      if on-sensor7?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]
      ; sensor8
      let on-sensor8? false
      ask patch-here [if sensor8? [set on-sensor8? true]]
      if on-sensor8?
      [
        ifelse pcolor = red or (not clear-on-other-side (20 + size))
        [set speed 0]
        [if speed = 0 [set speed .1]]
      ]

      ; intersection 0
      let in-intersection? false
      ask patch-here [if intersection? [set in-intersection? true]]
      if in-intersection?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light ?1 red ]
;        ]

        if source = 0
        [
          if destination = 4 or destination = 5 or destination = 6
          [
            if ycor >= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 1
        [
          if destination = 10
          [
            if ycor >= -5 [set heading 90]
          ]
          if destination = 4
          [
            if ycor >= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 2
        [
          if destination = 7 or destination = 8 or destination = 9
          [
            if xcor >= 5 [set heading 0]
          ]
        ]
        if source = 3
        [
          if destination = 7 or destination = 8 or destination = 9
          [
            if xcor >= 5 [set heading 0]
          ]
        ]
        if source = 4
        [
          if destination = 7
          [
            if xcor >= 5 [set heading 0]
          ]
          if destination = 1
          [
            if xcor >= -5 [set heading 180]
          ]
        ]
        if source = 5
        [
          if destination = 10 or destination = 11 or destination = 0
          [
            if ycor <= -5 [set heading 90]
          ]
        ]
        if source = 6
        [
          if destination = 10 or destination = 11 or destination = 0
          [
            if ycor <= -5 [set heading 90]
          ]
        ]
        if source = 7
        [
          if destination = 10
          [
            if ycor <= -5 [set heading 90]
          ]
          if destination = 4
          [
            if ycor <= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 8
        [
          if destination = 1 or destination = 2 or destination = 3
          [
            if xcor <= -5 [set heading 180]
          ]
        ]
        if source = 9
        [
          if destination = 1 or destination = 2 or destination = 3
          [
            if xcor <= -5 [set heading 180]
          ]
        ]
        if source = 10
        [
          if destination = 7
          [
            if xcor <= 5 [set heading 0]
          ]
          if destination = 1
          [
            if xcor <= -5 [set heading 180]
          ]
        ]
        if source = 11
        [
          if destination = 4 or destination = 5 or destination = 6
          [
            if ycor >= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
      ]

      ; intersection 1
      let in-intersection-1? false
      ask patch-here [if intersection-1? [set in-intersection-1? true]]
      if intersection-1?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light1 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light1 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light1 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light1 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 5 or destination = 6
          [
            if xcor <= -145 [set heading 0
              set shape "car"]
          ]
        ]
        if source = 2
        [
          if destination = 4
          [
            if ycor >= 5 [set heading 270
              set shape "car-inverted"]
          ]
          if destination = 7 or destination = 8 or destination = 9 or destination = 10
          [
            if ycor >= -5 [set heading 90]
          ]
        ]
        if source = 3
        [
          if destination = 4
          [
            if ycor >= 5 [set heading 270
              set shape "car-inverted"]
          ]
          if destination = 7 or destination = 8 or destination = 9 or destination = 10
          [
            if ycor >= -5 [set heading 90]
          ]
        ]
        if source = 4
        [
          if destination = 5 or destination = 6
          [
            if xcor >= -145 [set heading 0
              set shape "car"]
          ]
          if destination = 2 or destination = 3
          [
            if xcor >= -155 [set heading 180]
          ]
        ]
        if source = 5
        [
          if destination = 4
          [
            if ycor <= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 6
        [
          if destination = 4
          [
            if ycor <= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 10
        [
          if destination = 2 or destination = 3
          [
            if xcor <= -155 [set heading 180]
          ]
          if destination = 5 or destination = 6
          [
            if xcor <= -145 [set heading 0]
          ]
        ]
        if source = 11
        [
          if destination = 5 or destination = 6
          [
            if xcor <= -145 [set heading 0
              set shape "car"]
          ]
        ]
      ]

      ; intersection 2
      let in-intersection-2? false
      ask patch-here [if intersection-2? [set in-intersection-2? true]]
      if intersection-2?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light2 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light2 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light2 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light2 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 1
        [
          if destination = 6
          [
            if xcor <= -145 [set heading 0
              set shape "car"]
          ]
        ]
        if source = 2
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 3
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 4
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 5
        [
          ifelse destination = 6
          [
            if xcor >= -145 [set heading 0]
          ]
          [
            if destination = 2 or destination = 3 or destination = 4
            [
              if xcor >= -155 [set heading 180]
            ]
          ]
        ]
        if source = 6
        [
          ifelse destination = 5
          [
            if ycor <= 145 [set heading 270
              set shape "car-inverted"]
          ]
          [
            if destination != 2 and destination != 3 and destination != 4
            [
              if ycor <= 135 [set heading 90]
            ]
          ]
        ]
        if source = 7
        [
          if destination = 6
          [
            if xcor <= -145 [set heading 0
              set shape "car"]
          ]
        ]
        if source = 8
        [
          if destination = 6
          [
            if xcor <= -145 [set heading 0]
          ]
        ]
        if source = 9
        [
          if destination = 6
          [
            if xcor <= -145 [set heading 0]
          ]
        ]
        if source = 10
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 11
        [
          if destination = 5
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
      ]

      ; intersection 3
      let in-intersection-3? false
      ask patch-here [if intersection-3? [set in-intersection-3? true]]
      if intersection-3?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light3 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light3 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light3 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light3 ?1 red ]
;        ]

        if source = 1
        [
          if destination = 8 or destination = 9
          [
            if ycor >= 135 [set heading 90]
          ]
          if destination = 5 or destination = 6
          [
            if ycor >= 145 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 2
        [
          if destination = 8 or destination = 9
          [
            if ycor >= 135 [set heading 90]
          ]
        ]
        if source = 3
        [
          if destination = 8 or destination = 9
          [
            if ycor >= 135 [set heading 90]
          ]
        ]
        if source = 5
        [
          if destination = 7
          [
            if xcor >= 5 [set heading 0]
          ]
          if destination = 10 or destination = 11 or destination = 0 or destination = 1
          [
            if xcor >= -5 [set heading 180]
          ]
        ]
        if source = 6
        [
          if destination = 7
          [
            if xcor >= 5 [set heading 0]
          ]
          if destination = 10 or destination = 11 or destination = 0 or destination = 1
          [
            if xcor >= -5 [set heading 180]
          ]
        ]
        if source = 7
        [
          if destination = 5 or destination = 6
          [
            if ycor <= 145 [set heading 270
              set shape "car-inverted"]
          ]
          if destination = 8 or destination = 9
          [
            if ycor <= 135 [set heading 90]
          ]
        ]
        if source = 8
        [
          if destination = 7
          [
            if xcor <= 5 [set heading 0]
          ]
        ]
        if source = 9
        [
          if destination = 7
          [
            if xcor <= 5 [set heading 0]
          ]
        ]
      ]

      ; intersection 4
      let in-intersection-4? false
      ask patch-here [if intersection-4? [set in-intersection-4? true]]
      if intersection-4?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light4 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light4 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light5 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light6 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 9
          [
            if ycor >= 135 [set heading 90]
          ]
        ]
        if source = 1
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 2
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 3
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 4
        [
          if destination = 9
          [
            if ycor >= 135 [set heading 90]
          ]
        ]
        if source = 5
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 6
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 7
        [
          if destination = 8
          [
            if xcor >= 155 [set heading 0]
          ]
        ]
        if source = 8
        [
          ifelse destination = 9
          [
            if ycor <= 135 [set heading 90]
          ]
          [
            if destination = 5 or destination = 6 or destination = 7
            [
              if ycor <= 145 [set heading 270
                set shape "car-inverted"]
            ]
          ]
        ]
        if source = 9
        [
          ifelse destination = 8
          [
            if xcor <= 155 [set heading 0]
          ]
          [
            if destination != 5 and destination != 6 and destination != 7
            [
              if xcor <= 145 [set heading 180]
            ]
          ]
        ]
        if source = 10
        [
          if destination = 9
          [
            if ycor >= 135 [set heading 90
              set shape "car"]
          ]
        ]
        if source = 11
        [
          if destination = 9
          [
            if ycor >= 135 [set heading 90
              set shape "car"]
          ]
        ]
      ]

      ; intersection 5
      let in-intersection-5? false
      ask patch-here [if intersection-5? [set in-intersection-5? true]]
      if intersection-5?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light5 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light5 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light5 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light5 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 10
          [
            if ycor >= -5 [set heading 90]
          ]
        ]
        if source = 4
        [
          if destination = 8 or destination = 9
          [
            if xcor >= 155 [set heading 0]
          ]
          if destination = 0 or destination = 11
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 5
        [
          if destination = 11 or destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 6
        [
          if destination = 11 or destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 8
        [
          if destination = 10
          [
            if ycor <= -5 [set heading 90
              set shape "car"]
          ]
          if destination = 1 or destination = 2 or destination = 3 or destination = 4
          [
            if ycor <= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 9
        [
          if destination = 10
          [
            if ycor <= -5 [set heading 90
              set shape "car"]
          ]
          if destination = 1 or destination = 2 or destination = 3 or destination = 4
          [
            if ycor <= 5 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 10
        [
          if destination = 8 or destination = 9
          [
            if xcor <= 155 [set heading 0]
          ]
          if destination = 0 or destination = 11
          [
            if xcor <= 145 [set heading 180]
          ]
        ]
        if source = 11
        [
          if destination = 10
          [
            if ycor >= -5 [set heading 90
              set shape "car"]
          ]
        ]
      ]

      ; intersection 6
      let in-intersection-6? false
      ask patch-here [if intersection-6? [set in-intersection-6? true]]
      if intersection-6?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light6 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light6 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light6 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light6 ?1 red ]
;        ]

        if source = 0
        [
          ifelse destination = 11
          [
            if ycor >= -145 [set heading 90]
          ]
          [
            if destination != 8 and destination != 9 and destination != 10
            [
              if ycor >= -135 [set heading 270
                set shape "car-inverted"]
            ]
          ]
        ]
        if source = 1
        [
          if destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 2
        [
          if destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 3
        [
          if destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 4
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90]
          ]
        ]
        if source = 5
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90]
          ]
        ]
        if source = 6
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90]
          ]
        ]
        if source = 7
        [
          if destination = 0
          [
            if xcor >= 145 [set heading 180]
          ]
        ]
        if source = 8
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90
              set shape "car"]
          ]
        ]
        if source = 9
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90
              set shape "car"]
          ]
        ]
        if source = 10
        [
          if destination = 11
          [
            if ycor <= -145 [set heading 90
              set shape "car"]
          ]
        ]
        if source = 11
        [
          ifelse destination = 0
          [
            if xcor <= 145 [set heading 180]
          ]
          [
            if destination = 10 or destination = 8 or destination = 9
            [
              if xcor <= 155 [set heading 0]
            ]
          ]
        ]
      ]

      ; intersection 7
      let in-intersection-7? false
      ask patch-here [if intersection-7? [set in-intersection-7? true]]
      if intersection-7?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light7 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light7 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light7 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light7 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 1
          [
            if xcor <= -5 [set heading 180]
          ]
          if destination = 4 or destination = 5 or destination = 6 or destination = 7
          [
            if xcor <= 5 [set heading 0]
          ]
        ]
        if source = 1
        [
          if destination = 0 or destination = 11
          [
            if ycor >= -145 [set heading 90]
          ]
          if destination = 2 or destination = 3
          [
            if ycor >= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 2
        [
          if destination = 1
          [
            if xcor >= -5 [set heading 180]
          ]
        ]
        if source = 3
        [
          if destination = 1
          [
            if xcor >= -5 [set heading 180]
          ]
        ]
        if source = 7
        [
          if destination = 2 or destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
          if destination = 0 or destination = 11
          [
            if ycor <= -145 [set heading 90]
          ]
        ]
        if source = 8
        [
          if destination = 2 or destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 9
        [
          if destination = 2 or destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 11
        [
          if destination = 1
          [
            if xcor <= -5 [set heading 180]
          ]
          if destination = 4 or destination = 5 or destination = 6 or destination = 7
          [
            if xcor <= 5 [set heading 0]
          ]
        ]
      ]

      ; intersection 8
      let in-intersection-8? false
      ask patch-here [if intersection-8? [set in-intersection-8? true]]
      if intersection-8?
      [
;        if heading = 0
;        [
;          foreach [270] [ ?1 -> set-car-light8 ?1 red ]
;        ]
;        if heading = 90
;        [
;          foreach [0] [ ?1 -> set-car-light8 ?1 red ]
;        ]
;        if heading = 180
;        [
;          foreach [90] [ ?1 -> set-car-light8 ?1 red ]
;        ]
;        if heading = 270
;        [
;          foreach [180] [ ?1 -> set-car-light8 ?1 red ]
;        ]

        if source = 0
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
        if source = 1
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
        if source = 2
        [
          ifelse destination = 3
          [
            if ycor >= -135 [set heading 270
              set shape "car-inverted"]
          ]
          [
            if destination = 1 or destination = 0 or destination = 11
            [
              if ycor >= -145 [set heading 90]
            ]
          ]
        ]
        if source = 3
        [
          ifelse destination = 2
          [
            if xcor >= -155 [set heading 180]
          ]
          [
            if destination != 1 and destination != 0 and destination != 11
            [
              if xcor >= -145 [set heading 0]
            ]
          ]
        ]
        if source = 4
        [
          if destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 5
        [
          if destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 6
        [
          if destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 7
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
        if source = 8
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
        if source = 9
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
        if source = 10
        [
          if destination = 3
          [
            if ycor <= -135 [set heading 270
              set shape "car-inverted"]
          ]
        ]
        if source = 11
        [
          if destination = 2
          [
            if xcor <= -155 [set heading 180]
          ]
        ]
      ]

      fd speed
    ]
    [

      if direction = 0 [set count-carNSpass (count-carNSpass + 1)]
      if direction = 90 [set count-carEWpass (count-carEWpass + 1)]
      if direction = 180 [set count-carNSpass (count-carNSpass + 1)]
      if direction = 270 [set count-carEWpass (count-carEWpass + 1)]
      set count-carNSwait(count-carNS - count-carNSpass)
      set count-carEWwait(count-carEW - count-carEWpass)

      let wait-time (ticks - start-time)
      if wait-time > max-wait-time-cars [set max-wait-time-cars wait-time]
      if (min-wait-time-cars = 0) or (wait-time < min-wait-time-cars) [set min-wait-time-cars wait-time]
      set total-wait-time-cars (total-wait-time-cars + wait-time)
      set total-cars (total-cars + 1)
      set average-wait-time-cars (total-wait-time-cars / total-cars)

      die
    ]
  ]
end

to init-car [dir]
  set heading dir
  set direction dir

  if dir = 0 and xcor = 155 [set source 0]
  if dir = 0 and xcor = 5 [set source 1]
  if dir = 0 and xcor = -145 [set source 2]
  if dir = 90 and ycor = -145 [set source 3]
  if dir = 90 and ycor = -5 [set source 4]
  if dir = 90 and ycor = 135 [set source 5]
  if dir = 180 and xcor = -155 [set source 6]
  if dir = 180 and xcor = -5 [set source 7]
  if dir = 180 and xcor = 145 [set source 8]
  if dir = 270 and ycor = 145 [set source 9]
  if dir = 270 and ycor = 5 [set source 10]
  if dir = 270 and ycor = -135 [set source 11]

  ; Set Destination
  let r (random-float 1)
  ifelse r < 0.7
  [
    ifelse source = 0 or source = 2 or source = 3 or source = 5 or source = 6 or source = 8 or source = 9 or source = 11
    [
      set r (random-float 1)
      ifelse r < 0.5
      [
        set destination (source + 6)
      ]
      [
        set destination (source + 5)
      ]
      if destination >= 12
      [
        set destination (destination - 12)
      ]
    ]
    [
      set r (random 12)
      if r = source
      [
        while [r = source]
        [set r (random 12)]]
      set destination r
    ]
  ]
  [
    set r (random 12)
    if r = source
    [
      while [r = source]
      [set r (random 12)]]
    set destination r
  ]

;  let r (random 12)
;  if r = source
;  [
;    while [r = source]
;    [set r (random 12)]]
;  set destination r

  if destination = 0 [set color 7]
  if destination = 1 [set color 17]
  if destination = 2 [set color 27]
  if destination = 3 [set color 37]
  if destination = 4 [set color 47]
  if destination = 5 [set color 57]
  if destination = 6 [set color 67]
  if destination = 7 [set color 77]
  if destination = 8 [set color 87]
  if destination = 9 [set color 97]
  if destination = 10 [set color 107]
  if destination = 11 [set color 117]

  set size car-length
  set speed ((random 8) + 8) / 10
  set acceleration ((random-float 1) + 1) / 10
  if dir = 270 [set shape "car-inverted"]

  set start-time ticks
end

to check-ahead-and-react

  let current-speed speed

  ;; adjust if there's a car in front of you
  let found-car? false
  let dist 0
  let max-dist (size / 2) + ((car-length + 10) / 2) + 1

  while [dist <= max-dist and found-car? = false ]
  [
    let next-patch patch-ahead dist
    if next-patch != nobody
    [
      let car-ahead one-of turtles-on next-patch
      if car-ahead != nobody and is-car? car-ahead and car-ahead != self
      [
        set found-car? true
        set speed (([speed] of car-ahead) - acceleration)

        ;; type dist type " [" type size type "] " type "[" type [size] of car-ahead type "]"
        ;; slow the car down even more if it is overlapping another car
        if dist < size or dist < [size] of car-ahead [set speed 0]

      ]
    ]
    set dist (dist + 1)
  ]

  ;; if no car, accelerate
  if found-car? = false [set speed speed + acceleration]

  if speed < 0 [set speed 0 ]
  if speed > max-speed [set speed max-speed]

end

to-report clear-on-other-side [max-dist]

  let found-car? false
  let dist 0
  while [dist <= max-dist and found-car? = false ]
  [
    let next-patch patch-ahead dist
    if next-patch != nobody
    [
      let car-ahead one-of turtles-on next-patch
      if car-ahead != nobody and is-car? car-ahead and car-ahead != self
      [
        set found-car? true
      ]
    ]
    set dist (dist + 1)
  ]
  report not found-car?
end

to plot-data
  set-current-plot "Car Wait Time"
  set-current-plot-pen "max-wait-time"
  plot max-wait-time-cars
  set-current-plot-pen "min-wait-time"
  plot min-wait-time-cars
  set-current-plot-pen "avg-wait-time"
  ifelse total-cars != 0 [plot total-wait-time-cars / total-cars] [plot 0]
  set-current-plot-pen "total-cars"
  plot total-cars
end
@#$#@#$#@
GRAPHICS-WINDOW
460
47
1219
732
-1
-1
1.5
1
10
1
1
1
0
0
0
1
-250
250
-225
225
1
1
1
ticks
30.0

BUTTON
8
10
74
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
10
144
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
745
10
872
43
MN-car-density
MN-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
771
747
896
780
MS-car-density
MS-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
317
365
448
398
MW-car-density
MW-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
1241
374
1355
407
ME-car-density
ME-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SWITCH
9
57
144
90
show-sensors?
show-sensors?
0
1
-1000

SLIDER
5
365
192
398
green-light-duration
green-light-duration
0
1000
200.0
1
1
ticks
HORIZONTAL

CHOOSER
3
96
244
141
scheduling-algorithm
scheduling-algorithm
"SP-RR"
0

PLOT
3
202
299
349
Car Wait Time
ticks
wait time
0.0
1000.0
0.0
1000.0
true
true
"" ""
PENS
"max-wait-time" 1.0 0 -2674135 true "" ""
"min-wait-time" 1.0 0 -10899396 true "" ""
"avg-wait-time" 1.0 2 -11033397 true "" ""
"total-cars" 1.0 1 -955883 true "" ""

MONITOR
234
11
309
60
NIL
total-cars
17
1
12

MONITOR
146
10
230
59
NIL
average-wait-time-cars
17
1
12

MONITOR
6
412
99
461
NIL
count-carenter
17
1
12

SLIDER
510
10
641
43
LN-car-density
LN-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
320
167
438
200
TW-car-density
TW-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
1240
162
1352
195
TE-car-density
TE-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
542
749
677
782
LS-car-density
LS-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
1002
10
1125
43
RN-car-density
RN-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
326
597
451
630
DW-car-density
DW-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
1012
749
1132
782
RS-car-density
RS-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
1243
583
1353
616
DE-car-density
DE-car-density
0
100
25.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ambulance
true
0
Rectangle -7500403 true true 90 90 195 270
Polygon -7500403 true true 190 4 150 4 134 41 104 56 105 90 190 90
Rectangle -1 true false 60 105 105 105
Polygon -16777216 true false 112 62 141 48 141 81 112 82
Circle -16777216 true false 174 24 42
Circle -16777216 true false 174 189 42
Rectangle -1 true false 158 3 173 12
Rectangle -1184463 true false 180 2 172 11
Rectangle -2674135 true false 151 2 158 271
Line -16777216 false 90 90 195 90
Rectangle -16777216 true false 116 172 133 217
Rectangle -16777216 true false 111 124 134 147
Line -7500403 true 105 135 135 135
Rectangle -7500403 true true 186 267 195 286
Line -13345367 false 135 255 120 225
Line -13345367 false 135 225 120 255
Line -13345367 false 112 240 142 240

ambulance-inverted
true
0
Rectangle -7500403 true true 105 90 210 270
Polygon -7500403 true true 110 4 150 4 166 41 196 56 195 90 110 90
Rectangle -1 true false 195 105 240 105
Polygon -16777216 true false 188 62 159 48 159 81 188 82
Circle -16777216 true false 84 24 42
Circle -16777216 true false 84 189 42
Rectangle -1 true false 127 3 142 12
Rectangle -1184463 true false 128 2 120 11
Rectangle -2674135 true false 142 2 149 271
Line -16777216 false 210 90 105 90
Rectangle -16777216 true false 167 172 184 217
Rectangle -16777216 true false 166 124 189 147
Line -7500403 true 195 135 165 135
Rectangle -7500403 true true 105 267 114 286
Line -13345367 false 165 255 180 225
Line -13345367 false 165 225 180 255
Line -13345367 false 188 240 158 240

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
true
0
Polygon -7500403 true true 180 0 164 21 144 39 135 60 132 74 106 87 84 97 63 115 50 141 50 165 60 225 150 300 165 300 225 300 225 0 180 0
Circle -16777216 true false 180 30 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 80 138 78 168 135 166 135 91 105 106 96 111 89 120
Circle -7500403 true true 195 195 58
Circle -7500403 true true 195 47 58

car side
false
0
Polygon -7500403 true true 19 147 11 125 16 105 63 105 99 79 155 79 180 105 243 111 266 129 253 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 101 87 73 108 171 108 151 87
Line -8630108 false 121 82 120 108
Polygon -1 true false 242 121 248 128 266 129 247 115
Rectangle -16777216 true false 12 131 28 143

car-inverted
true
0
Polygon -7500403 true true 120 0 136 21 156 39 165 60 168 74 194 87 216 97 237 115 250 141 250 165 240 225 150 300 135 300 75 300 75 0 120 0
Circle -16777216 true false 30 30 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 220 138 222 168 165 166 165 91 195 106 204 111 211 120
Circle -7500403 true true 47 195 58
Circle -7500403 true true 47 47 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person-student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

traffic-light-green
false
15
Rectangle -7500403 true false 60 15 75 300
Line -7500403 false 75 195 90 195
Line -7500403 false 75 45 90 45
Rectangle -7500403 true false 90 30 150 210
Circle -16777216 true false 99 39 42
Circle -16777216 true false 99 99 42
Circle -13840069 true false 99 159 42

traffic-light-green-flat
false
15
Rectangle -7500403 true false 60 120 210 180
Circle -16777216 true false 75 135 30
Circle -16777216 true false 120 135 30
Circle -13840069 true false 165 135 30

traffic-light-green-inverse
false
15
Rectangle -7500403 true false 165 30 180 315
Line -7500403 false 150 195 165 195
Line -7500403 false 150 45 165 45
Rectangle -7500403 true false 90 30 150 210
Circle -16777216 true false 99 39 42
Circle -16777216 true false 99 99 42
Circle -13840069 true false 99 159 42

traffic-light-red
false
15
Rectangle -7500403 true false 60 15 75 300
Line -7500403 false 75 195 90 195
Line -7500403 false 75 45 90 45
Rectangle -7500403 true false 90 30 150 210
Circle -2674135 true false 99 39 42
Circle -16777216 true false 99 99 42
Circle -16777216 true false 99 159 42

traffic-light-red-inverse
false
15
Rectangle -7500403 true false 165 15 180 300
Line -7500403 false 150 195 165 195
Line -7500403 false 150 45 165 45
Rectangle -7500403 true false 90 30 150 210
Circle -2674135 true false 99 39 42
Circle -16777216 true false 99 99 42
Circle -16777216 true false 99 159 42

traffic-light-yellow
false
15
Rectangle -7500403 true false 60 15 75 300
Line -7500403 false 75 195 90 195
Line -7500403 false 75 45 90 45
Rectangle -7500403 true false 90 30 150 210
Circle -16777216 true false 99 39 42
Circle -1184463 true false 99 99 42
Circle -16777216 true false 99 159 42

traffic-light-yellow-inverse
false
15
Rectangle -7500403 true false 165 15 180 300
Line -7500403 false 150 195 165 195
Line -7500403 false 150 45 165 45
Rectangle -7500403 true false 90 30 150 210
Circle -16777216 true false 99 39 42
Circle -1184463 true false 99 99 42
Circle -16777216 true false 99 159 42

train
false
0
Rectangle -7500403 true true 30 105 240 150
Polygon -7500403 true true 240 105 270 30 180 30 210 105
Polygon -7500403 true true 195 180 270 180 300 210 195 210
Circle -7500403 true true 0 165 90
Circle -7500403 true true 240 225 30
Circle -7500403 true true 90 165 90
Circle -7500403 true true 195 225 30
Rectangle -7500403 true true 0 30 105 150
Rectangle -16777216 true false 30 60 75 105
Polygon -7500403 true true 195 180 165 150 240 150 240 180
Rectangle -7500403 true true 135 75 165 105
Rectangle -7500403 true true 225 120 255 150
Rectangle -16777216 true false 30 203 150 218

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -1 true false 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

truck-rotate
true
0
Rectangle -1 true false 45 105 187 296
Polygon -7500403 true true 193 4 150 4 134 41 104 56 104 92 194 93
Rectangle -1 true false 60 105 105 105
Polygon -16777216 true false 112 62 141 48 141 81 112 82
Circle -16777216 true false 174 24 42
Rectangle -7500403 true true 185 86 194 119
Circle -16777216 true false 174 114 42
Circle -16777216 true false 174 234 42
Circle -7500403 false true 174 234 42
Circle -7500403 false true 174 114 42
Circle -7500403 false true 174 24 42

truck-rotate-inverted
true
0
Rectangle -1 true false 113 105 255 296
Polygon -7500403 true true 107 4 150 4 166 41 196 56 196 92 106 93
Rectangle -1 true false 195 105 240 105
Polygon -16777216 true false 188 62 159 48 159 81 188 82
Circle -16777216 true false 84 24 42
Rectangle -7500403 true true 106 86 115 119
Circle -16777216 true false 84 114 42
Circle -16777216 true false 84 234 42
Circle -7500403 false true 84 234 42
Circle -7500403 false true 84 114 42
Circle -7500403 false true 84 24 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

van side
false
0
Polygon -7500403 true true 26 147 18 125 36 61 161 61 177 67 195 90 242 97 262 110 273 129 260 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 45 68 37 95 183 96 169 69
Line -7500403 true 62 65 62 103
Line -7500403 true 115 68 120 100
Polygon -1 true false 271 127 258 126 257 114 261 109
Rectangle -16777216 true false 19 131 27 142

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>total-cars = 1000</exitCondition>
    <metric>max-wait-time-cars</metric>
    <metric>total-wait-time-cars</metric>
    <metric>total-cars</metric>
    <metric>max-wait-time-pedestrians</metric>
    <metric>total-wait-time-pedestrians</metric>
    <metric>total-pedestrians</metric>
    <enumeratedValueSet variable="show-sensors?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scheduling-algorithm">
      <value value="&quot;round-robin&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="green-light-duration" first="100" step="100" last="500"/>
    <enumeratedValueSet variable="orange-light-duration">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="all-red-duration">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="train-frequency">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-car-density">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="E-car-density">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="W-car-density">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-car-density">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-trucks">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-emergency-vehicles">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-turning-left">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-turning-right">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="W-pedestrian-density">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="S-pedestrian-density">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="E-pedestrian-density">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-pedestrian-density">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
