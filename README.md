Page:     me -page portrait∕landscape∕square      │Using:       me -u '1:($2>0?$2:1/0)'
Font:     me -font cm∕arial∕times【,13】          │With:        me -w l∕p
Merge:    me -m0∕-ma∕-mc∕-mf                      │Dash type:   me -dt 1
Layout:   me -N【number】∕-Z【number】            │Line width:  me -lw 2
Space:    me -space 10,10                         │Point type:  me -pt 7
──────<-- combine with figure -a -->───────────── │Point size:  me -ps 0.5
Figure:   me -a∕-b∕-c∕···                         │Line color:  me -lc 6∕palette
Datafile: me xxx.txt yyy.txt                      │──────<-- combine with line -a1 -->──────────────
X-column: me -u '1:c'                             │Swap:        me -swap 【a1】【a2】
Y-column: me [2:8]                                │Move:        me -move 【a1】【a2】
Size:     me -size 200,134                        │──────<-- combine with figure -a -->─────────────
Offset:   me -offset 10,20                        │Graph:       me -graph 2d∕3d∕map
Index:    me -I '(A)'∕on∕off                      │Z-label:     me -zl '{s/D}{//E}'
Caption:  me -ic '{s/D}{//E}..=..0.5'             │Z-range:     me -zr 0.1:0.4
Position: me -ip 【position】                     │Z-tics:      me -zt 0.1
X-label:  me -xl '{//E}'                          │View:        me -view rot-x,rot-z
X-range:  me -xr -pi:pi                           │Pm3d:        me -pm3d on∕off【∕colormap】
X-tics:   me -xt 1                                │Axis3d:      me -axis3d on∕off
Y-label:  me -yl '{s//r}({//E})'                  │──────<-- only used as graph=map -->─────────────
Y-range:  me -yr 0.1:0.4                          │Color-box:   me -cb vertical∕horizontal
Y-tics:   me -yt 0.1                              │Color-range: me -cr 0.1:0.4
──────<-- combine with figure -a -->───────────── │Color-tics:  me -ct 1
Key box:  me -kb -0.5【∕on∕off】                  │─────────────────────────────────────────────────
Position: me -kp 【position】                     │Tile:        me -vtile∕-htile 【space】【files】
──────<-- combine with line -a1 -->────────────── │GnuPlot:     me -gp
Line:     me -a1∕-a2∕-a3∕···                      │EPS file:    me -eps
Key:      me -K 【text】∕vertical∕horizontal      │Export:      me -export 【filename】
Label:    me -L 【text】                          │Output:      me -O 【filename】
Position: me -lp 【position【,fontsize】】        │             me -new∕-update



<-- Fonts -->                                     │<-- Position -->
    {/ }    (Roman)                               │ sh  hl    h    hr        (s:slash) (h:header)
    {// }   (Italic)                              │    ┌──────┬──────┐
    {b/ }   (Bold)                                │    │tl    t    tr│ to    (o:outside)
    {b// }  (Bold-Italic)                         │    │      │      │
    {s/ }   (Symbol)                              │    ├l ─── c ─── r┤ o
    {s// }  (Symbol-Oblique)                      │    │      │      │
    {w/ }   (Artistic)                            │    │bl    b    br│ bo
<-- Greek Letters -->                             │    └──────┴──────┘
    A:A    B:B    C:Χ    D:Δ    E:Ε    F:Φ        │     0.5,0.5,center【,fontsize】
    G:Γ    H:Η    I:Ι    K:Κ    L:Λ    M:M        │────────────────────────────────────────────────
    N:N    O:O    P:Π    Q:Θ    R:Ρ    S:Σ        │<-- Colormaps of Pm3d -->
    T:Τ    U:Υ    W:Ω    X:Ξ    Y:Ψ    Z:Z        │    heat     ▬▬▬▬▬▬▬▬▬▬▬▬
    a:α    b:β    c:χ    d:δ    e:ε    f:φ        │    jet      ▬▬▬▬▬▬▬▬▬▬▬▬
    g:γ    h:η    i:ι    k:κ    l:λ    m:μ        │    parula   ▬▬▬▬▬▬▬▬▬▬▬▬  (default)
    n:ν    o:ο    p:π    q:θ    r:ρ    s:σ        │    viridis  ▬▬▬▬▬▬▬▬▬▬▬▬
    t:τ    u:υ    w:ω    x:ξ    y:ψ    z:ζ        │    green
<-- Math Symbols -->                              │    grey
    \245:∞    \261:±    \265:∝    \271:≠          │────────────────────────────────────────────────
    \273:≈    \320:∠    \077:⊥    \153:∥          │<-- Numerics -->
───────────────────────────────────────────────── │Transpose:   me -tra
<-- Blank -->                                     │Calculation: me -cal '$1*sin(30)'
    {}    (delete)                                │Derivative:  me -der d3/d1
    ^.    (quarter-space: "^.")                   │Integral:    me -int 'exp($2-c1)*d1'
    ..    (half-space: ".")                       │Fourier:     me -fft 1:2【:3】
    ,,    (three-quarters-space whitespace: " ")  │BZ Offset:   me -bz pi,pi
    __    (full-space: "A")                       │
