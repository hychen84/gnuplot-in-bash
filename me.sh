#!/bin/bash -f
# 
# ME is a bash shell script using gnuplot to make a ps file.
#
# ME build 7.5.404 released on 2025-08-31 (since 2007/12/25)
#
# This work is licensed under a creative commons
# Attribution-Noncommercial-ShareAlike 4.0 International
#
# Dr. Hong-Yi Chen
# Department of Physics, National Taiwan Normal University, Taipei 116, Taiwan
# Email: hongyi at ntnu.edu.tw
#
Arg=($*)

function save_parameters() {
	arraytostring() {
		declare -n aa=$1
		if [ ${#aa[*]} -gt 0 ]; then
			for key in ${!aa[*]}; do
				echo -n "[$key]=\"${aa[$key]}\" "
			done
		else
            if [ ${2%=*} == "[0]" ]; then echo -n "[0]=\"${2#*=}\" "
            elif [ ${2%=*} == "[0,0]" ]; then echo -n "[0,0]=\"${2#*=}\" "
            elif [ ${2%=*} == "[0,1]" ]; then echo -n "[0,1]=\"${2#*=}\" "
			fi
            if [[ ${3%=*} == "[N]" ]]; then echo "[N]=\"${3#*=}\""
            else echo
			fi
        fi
	}
	echo "Output=${Output:-fig}
FS=\"${FS:- }\"
Dpi=${Dpi:-96}
Page=${Page:-portrait}
Pagewidth=${Pagewidth:-21.0}
Pageheight=${Pageheight:-29.7}
Font=${Font:-Times}
Fontsize=${Fontsize:-13}
Digitscale=${Digitscale:-0.67}
Labelmargin=${Labelmargin:-1.0}
Keymargin=${Keymargin:-0.5}
Merge=${Merge:-c}
Align=(${Align[*]:-Z 2})
Hspace=${Hspace:-*}
Vspace=${Vspace:-*}
Total_figures=${Total_figures:-0}
Layout=(${Layout[*]:-1 1})
declare -A Files=($(arraytostring Files [0,0]='' [N]='0'))
declare -A Columns=($(arraytostring Columns [0,0]='2' [N]='1'))
declare -a Graph=($(arraytostring Graph [0]='2d'))
declare -a Xsite=($(arraytostring Xsite [0]='0'))
declare -a Ysite=($(arraytostring Ysite [0]='0'))
declare -a Hoffset=($(arraytostring Hoffset [0]='0'))
declare -a Voffset=($(arraytostring Voffset [0]='0'))
declare -a Xsize=($(arraytostring Xsize [0]='200'))
declare -a Ysize=($(arraytostring Ysize [0]='134'))
declare -a Index=($(arraytostring Index [0]='(a)'))
declare -a Caption=($(arraytostring Caption [0]=''))
declare -a Index_position=($(arraytostring Index_position [0]='auto'))
declare -A Label=($(arraytostring Label [0]='0'))
declare -A Label_position=($(arraytostring Label_position [0,1]='0.5,0.5,center'))
declare -A Key=($(arraytostring Key [0,1]=''))
declare -a Key_box=($(arraytostring Key_box [0]='on'))
declare -a Key_layout=($(arraytostring Key_layout [0]='vertical■maxcols■1'))
declare -a Key_position=($(arraytostring Key_position [0]='auto'))
declare -a Xlabel=($(arraytostring Xlabel [0]=''))
declare -a Ylabel=($(arraytostring Ylabel [0]=''))
declare -a Zlabel=($(arraytostring Zlabel [0]=''))
declare -a Xrange=($(arraytostring Xrange [0]='*:*'))
declare -a Yrange=($(arraytostring Yrange [0]='*:*'))
declare -a Zrange=($(arraytostring Zrange [0]='*:*'))
declare -a Crange=($(arraytostring Crange [0]='*:*'))
declare -a Xtics=($(arraytostring Xtics [0]='auto'))
declare -a Ytics=($(arraytostring Ytics [0]='auto'))
declare -a Ztics=($(arraytostring Ztics [0]='auto'))
declare -a Ctics=($(arraytostring Ctics [0]='auto'))
declare -a Cbox=($(arraytostring Cbox [0]='vertical'))
declare -a View=($(arraytostring View [0]='60,52.5'))
declare -a Pm3d=($(arraytostring Pm3d [0]='off'))
declare -a Palette=($(arraytostring Palette [0]='PARULA'))
declare -a Axis3d=($(arraytostring Axis3d [0]='on'))
declare -a Plot=($(arraytostring Plot [0]='1'))
declare -A Using=($(arraytostring Using [0,1]='1:c'))
declare -A With=($(arraytostring With [0,1]='l'))
declare -A Dt=($(arraytostring Dt [0,1]='1'))
declare -A Lw=($(arraytostring Lw [0,1]='2'))
declare -A Pt=($(arraytostring Pt [0,1]='7'))
declare -A Ps=($(arraytostring Ps [0,1]='0.5'))
declare -A Lc=($(arraytostring Lc [0,1]='c'))
BZoffset=(${BZoffset[*]:-pi pi})" > .me/.var
}

function print_parameters() {
	if [ ! -f .me/table ]; then
		if [ ${Graph[0]} == "2d" ]; then
			echo "0 1 (a) plot datafile 1:2 l 1 2 7 0.5 1 \"\" x *:* auto y *:* auto" > .me/table
		else
			echo "0 1 (a) splot datafile 1:2:3 l 1 2 7 0.5 1 \"\" x *:* auto y *:* auto z *:* auto" > .me/table
		fi
	fi
    for ((i=0; i<Total_figures; i++)); do
        [[ ${Label[$i]} > 0 ]] && Lstr[$i]="L" || Lstr[$i]="\"\""
    done
    awk -v align=${Align[0]} -v xsite="${Xsite[*]}" -v ysite="${Ysite[*]}" -v lstr="${Lstr[*]}" '
    function separator(i,x) {
        if (i < x) {
            if (align == "N") {printf "│"} else {printf " "}
        }
    }
	function separate_line() {
		if (align == "N") {
			for (i=0; i<=x; i++) {
				printf "   \033[2m"
				for (k=0; k<L[i]+3; k++) printf "─"
				if (i < x) printf "  \033[0m│"
			}
			printf "\033[0m\n"
		} else {
			for (k=0; k<=h_line+x*3-1; k++) printf "─"
			printf "\n"
		}
	}
	function show_info() {
		separate_line()
		for (i=0; i<=x; i++) {
            split(A[i][j][1],c," ")
			w25 = L[i] - length(c[25] c[26] c[27]) - 11
			printf "    【%s】 Size=（%s,%s）%*s",c[25],c[26],c[27],w25," "
			separator(i,x)
		}
		printf "\n"
	}
    BEGIN {split(xsite,Xsite," "); split(ysite,Ysite," "); split(lstr,Lstr," ")}
    {
        x = Xsite[$1+1]
        y = Ysite[$1+1]
        A[x][y][$2] = $0
        N[y] = N[y] > $2 ? N[y] : $2
        L_cap[x] = L_cap[x] > length($3) ? L_cap[x] : length($3)
		L_data[x] = L_data[x] > length($5 $6) ? L_data[x] : length($5 $6)
        switch($7) {
            case "¶":
                L_style[x] = 0
                break
            case "pm3d":
                L_style[x] = 4
                break
            case "p":
                L_style[x] = L_style[x] > length($10 $11) ? L_style[x] : length($10 $11)
                break
            default:
                L_style[x] = L_style[x] > length($8 $9) ? L_style[x] : length($8 $9)
                break
        }
        L_label[x][y] = L_label[x][y] > length($14) ? L_label[x][y] : length($14)
        L_label[x][y] = L_label[x][y] > length($17) ? L_label[x][y] : length($17)
        L_label[x][y] = L_label[x][y] > length($20) ? L_label[x][y] : length($20)
        L_range[x][y] = L_range[x][y] > length($15) ? L_range[x][y] : length($15)
        L_range[x][y] = L_range[x][y] > length($18) ? L_range[x][y] : length($18)
        L_range[x][y] = L_range[x][y] > length($21) ? L_range[x][y] : length($21)
        L_range[x][y] = L_range[x][y] > length($23) ? L_range[x][y] : length($23)
        L[x] = L[x] > L_cap[x] ? L[x] : L_cap[x]
		L[x] = L[x] > (L_data[x]+6)+(L_style[x]+8) ? L[x] : (L_data[x]+6)+(L_style[x]+8)
        L[x] = L[x] > (L_range[x][y]+6)+(L_label[x][y]+6) ? L[x] : (L_range[x][y]+6)+(L_label[x][y]+6)
		if (Graph != $25) {Graph = $25; show_on ++}
        if (Xsize != $26) {Xsize = $26; show_on ++}
        if (Ysize != $27) {Ysize = $27; show_on ++}
		if ($13 != "\"\"") {Kstr[$1] = "K"}
    }
    END {
        for (j=0; j<=y; j++) {
			Graph = 0
            for (l=1; l<=N[j]; l++) {
                if (l == 1) {
					h_line = 0
                    for (i=0; i<=x; i++) {
                        split(A[i][j][1],c," ")
                        if (Lstr[c[1]+1] == "L" || Kstr[c[1]] == "K") {
							gsub("\"","",Lstr[c[1]+1])
							LK = "[" Lstr[c[1]+1] Kstr[c[1]] "]"
						} else {
                            LK = " "
                        }
                        w3 = L[i] - length(c[3])
                        if (c[3] !~ "🗙") {
							gsub("■"," ",c[3])
							printf "\033[2m%c: \033[0m%s%*s\033[90m%4s\033[0m ",c[1]+97,c[3],w3," ",LK
                        } else {
							split(c[3],d,"■")
							w3 = d[2] == "" ? w3-1 : w3
							printf "\033[2m%c: %s \033[0m%s%*s\033[90m%4s\033[0m ",c[1]+97,d[1],d[2],w3," ",LK
                        }
                        separator(i,x)
                        h_line += L[i] + 6
                    }
                    printf "\n"
                }
                for (i=0; i<=x; i++) {
                    split(A[i][j][l],c," ")
					gsub("§","$",c[6])
                    gsub("‖","||",c[6])
                    if (c[7]) {
                        switch(c[7]) {
                            case "l":
                                w = L[i] - (length(c[5] c[6] c[8] c[9])+14) + 2
                                printf "   %2d. \"%s\" u %s dt %s lw %s%*s",c[2],c[5],c[6],c[8],c[9], w," "
                                break
                            case "p":
                                w = L[i] - (length(c[5] c[6] c[10] c[11])+14) + 2
                                printf "   %2d. \"%s\" u %s pt %s ps %s%*s",c[2],c[5],c[6],c[10],c[11], w," "
                                break
                            case "lp":
                                w = L[i] - (length(c[5] c[6] c[8] c[10])+14) + 2
                                printf "   %2d. \"%s\" u %s dt %s pt %s%*s",c[2],c[5],c[6],c[8],c[10], w," "
                                break
                            case "pm3d":
                                w = L[i] - (length(c[5] c[6])+11) + 2
                                printf "   %2d. \"%s\" u %s pm3d%*s",c[2],c[5],c[6], w," "
                                break
                            case "¶":
                                w = L[i] - (length(c[5] c[6])+6) + 2
                                printf "   %2d. \"%s\" u %s%*s",c[2],c[5],c[6], w," "
                                break
                            default:
                                w = L[i] - (length(c[5] c[6] c[7])+7) + 2
                                printf "   %2d. \"%s\" u %s %s%*s",c[2],c[5],c[6],c[7], w," "
                                break
                        }
                    } else {
                        printf "%*s",L[i]+8," "
                    }
                    separator(i,x)
                }
                printf "\n"
			}
			for (i=0; i<=x; i++) {
				split(A[i][j][1],c," ")
				gsub("¶","",c[14])
				w15 = L_range[i][j] - length(c[15]) + 1
				w14 = L[i] - (L_range[i][j]+6) - (length(c[14])+5) + 1
				printf "    xr=［%s］,%*sxl=\"%s\"%*s",c[15], w15," ",c[14], w14," "
				separator(i,x)
			}
			printf "\n"
			for (i=0; i<=x; i++) {
				split(A[i][j][1],c," ")
				gsub("¶","",c[17])
				w18 = L_range[i][j] - length(c[18]) + 1
				w17 = L[i] - (L_range[i][j]+6) - (length(c[17])+5) + 1
				printf "    yr=［%s］,%*syl=\"%s\"%*s",c[18], w18," ",c[17], w17," "
				separator(i,x)
			}
			printf "\n"
			for (i=0; i<=x; i++) {
				split(A[i][j][1],c," ")
				if (c[4] == "splot") {Graph ++}
			}
			if (Graph > 0) {
				for (i=0; i<=x; i++) {
					split(A[i][j][1],c," ")
					gsub("¶","",c[20])
					w21 = L_range[i][j] - length(c[21]) + 1
					w20 = L[i] - (L_range[i][j]+6) - (length(c[20])+5) + 1
					if (c[25] == "map")     {printf "    cr=［%s］%*s",c[23],L[i]-(L_range[i][j]+5)+2," "}
					else if (c[25] == "3d") {printf "    zr=［%s］,%*szl=\"%s\"%*s",c[21], w21," ",c[20], w20," "}
					else {printf "%*s",L[i]+8," "}
					separator(i,x)
				}
				printf "\n"
			}
            if (j < y) {
                if (align == "N" && show_on == 3) {
                    for (i=0; i<x; i++) printf "%*s│", L[i]+8, " "
                    printf "\n"
                } else {
                    if (show_on > 3) show_info()
					separate_line()
				}
			}
		}
		if (show_on > 3) {j--; show_info()}
        if (h_line < 86) h_line = 86
		for (k=0; k<=h_line+x*3-1; k++) printf "─"
		printf "\n"
    }' .me/table
	IFS=""
	show_on=$(awk "BEGIN {print ${#Xsize[*]}*${#Ysize[*]}*${#Graph[*]}}")
	if [[ $show_on == 1 ]]; then
		echo "【$Graph】Merge=$Merge  Align=${Align[*]}  Space=（$Hspace,$Vspace） Size=（$Xsize,$Ysize） Font=$Font,$Fontsize  FS=\"$FS\"  Output=${Output:-fig}"
	else
		echo "Merge=$Merge  Align=${Align[*]}  Space=（$Hspace,$Vspace） Font=$Font,$Fontsize  FS=\"$FS\"  Output=${Output:-fig}"
		fi
	exit
}

function align_parameters() {
	echo "${2//—/ }" | awk -v L=$1 '
	{
		for (i=1; i<=NF; i++) {
			if ((i-1)%L == 0) {Lj=1; n++; A[n]=L-1}
            gsub("■","",$i)
			Larr[Lj] = Larr[Lj] < length($i) ? length($i) : Larr[Lj]
            g = gsub("¶","",$i)
            Darr[Lj][n] = $i
            Carr[Lj][n] = g
            if (g > 0) {A[n] -= 2}
			#print Lj, n, A[n], Carr[Lj][n], Darr[Lj][n], Larr[Lj]
            Lj++
		}
	}
	END {
        for (i=1; i<=n; i++) {
            if (A[i] == 0) continue
            printf "   "
            for (j=1; j<Lj; j++) {
                if (Carr[j+1][i] > 0 || Carr[j][i] > 0) {
                    printf " \033[2m%*-s\033[0m",Larr[j],Darr[j][i]
                } else {
                    printf " %*-s",Larr[j],Darr[j][i]
                }
                if (j==1) printf ":"
                if ((j-1)%2 == 0) printf " "
            }
            printf "\n"
        }
	}'
}

[ ! -d .me ] && mkdir .me
[ ! -f .me/.var ] && save_parameters
source .me/.var
[ $Total_figures -eq 0 ] && rm .me/table 2> /dev/null
[ $# == 0 ] && print_parameters && exit

#-========-========-======-==-=======-=======-====-=========-======---===-==-

function chr() {
	[ "$1" -lt 256 ] || return 1
	printf "\\$(printf %o "$1")"
}

function ord() {
	LC_CTYPE=C printf %3d "'$1"
}

function choose() {
	this=$(($(ord ${1%%[0-9]*})-97))
	if [ $this -le $Total_figures ]; then
		thisline=${1#[a-z]}
	else
		this=''
		thisline=''
	fi
}

function get_file() {
	if [[ $this && $thisline ]]; then
		[[ $((thisline-1)) > ${Files[$this]:-0} ]] && thisline=$((${Files[$this]:-0}+1))
		[[ ${Files[$this,$thisline]} == "" ]] && ((Files[$this]++))
		Files[$this,$thisline]=${datafile[0]}
	elif [ $this ]; then
        for ((i=1; i<=${Files[$this]:-0}; i++)); do
            unset Files[$this,$i]
        done
		if [[ $datafile == "." ]]; then
			Files[$this]=0
			return
		fi
        for ((i=1; i<=${#datafile[*]}; i++)); do
            Files[$this,$i]=${datafile[$i-1]}
        done
        Files[$this]=${#datafile[*]}
    else
        Files=()
        for ((i=0; i<${#datafile[*]}; i++)); do
            Files[$i,0]=${datafile[$i]}
        done
		Files["N"]=${#datafile[*]}
    fi
}

function get_column() {
	c=${1//[\[\]]/}
	if [ "${c//[^:]/}" == ":" -o "${c//[^:]/}" == "::" ]; then # [2:8:2]
		a=$(awk -v col=$c '
		BEGIN {
			split(col,c,":")
			b = c[2] - c[1]
			if (c[3]) {
				t = c[3]
			} else {
				t = b>0 ? 1 : -1
			}
			b = int(b / t)
			for (i=0; i<=b; i++) {
				P = P" "c[1]+t*i
			}
			print P
		}')
		cols=($a)
	else # [2,3,6,7] or [2]
		cols=(${c//,/ })
	fi
	if [[ $this && $thisline ]]; then
		[[ $((thisline-1)) > ${Columns[$this]:-0} ]] && thisline=$((${Columns[$this]:-0}+1))
		[[ ${Columns[$this,$thisline]} == "" ]] && ((Columns[$this]++))
		Columns[$this,$thisline]=${cols[0]}
	elif [ $this ]; then
        for ((i=1; i<=${Columns[$this]:-0}; i++)); do
            unset Columns[$this,$i]
        done
        for ((i=1; i<=${#cols[*]}; i++)); do
            Columns[$this,$i]=${cols[$i-1]}
        done
        Columns[$this]=${#cols[*]}
    else
        Columns=()
        for ((i=0; i<${#cols[*]}; i++)); do
            Columns[$i,0]=${cols[$i]}
        done
		Columns["N"]=${#cols[*]}
    fi
}

function set_graph() {
    Graph[${this:-0}]=${1,,}
	case ${1,,} in
		2d) Xsize[${this:-0}]=200
            Ysize[${this:-0}]=134
            Using[${this:-0},1]=1:c
            With[${this:-0},1]=l
			Index_position[${this:-0}]="auto";;
	    3d) Xsize[${this:-0}]=200
			Ysize[${this:-0}]=186
			Using[${this:-0},1]=1:2:c
			With[${this:-0},1]=pm3d
			Pm3d[${this:-0}]=on
			Index_position[${this:-0}]="auto";;
	   map) Xsize[${this:-0}]=150
			Ysize[${this:-0}]=150
			Using[${this:-0},1]=1:2:c
			With[${this:-0},1]=¶
			Index_position[${this:-0}]="auto";;
        {}) unset Graph[${this:-0}];;
         *) exit;;
	esac
	[[ $1 == "" ]] && echo "Graph:"
}

function set_csparameters() {
	if [[ $2 != "" ]]; then
		p1=${2%,*}
		p2=${2#*,}
		case $1 in
		   Space) if [[ $2 == "," ]]; then
					  Hspace=*; Vspace=*
				  else
					  Hspace=${p1:-$Hspace}; Vspace=${p2:-$Vspace}
				  fi
				  echo "    Space= \"$Hspace,$Vspace\"";;
		  Offset) if [[ $2 == "," ]]; then
					  Hoffset[${this:-0}]=0; Voffset[${this:-0}]=0
				  else
					  Hoffset[${this:-0}]=${p1:-${Hoffset[${this:-0}]:-${Hoffset[0]}}}
					  Voffset[${this:-0}]=${p2:-${Voffset[${this:-0}]:-${Voffset[0]}}}
				  fi
				  echo "    $(chr $((${this:-0}+97))):  Offset= \"${Hoffset[${this:-0}]},${Voffset[${this:-0}]}\"";;
			Size) getclosestkey Xsize ${this:-0}; Xsize[${this:-0}]=${p1:-${Xsize[${this:-0}]:-${Xsize[t]}}}
				  getclosestkey Ysize ${this:-0}; Ysize[${this:-0}]=${p2:-${Ysize[${this:-0}]:-${Ysize[t]}}}
				  echo "    $(chr $((${this:-0}+97))):  Size= \"${Xsize[${this:-0}]},${Ysize[${this:-0}]}\"";;
			View) View[${this:-0}]=${p1:-${View[${this:-0}]%,*}},${p2:-${View[${this:-0}]#*,}}
				  echo "    $(chr $((${this:-0}+97))):  view= \"${View[${this:-0}]}\"";;
		esac
	elif [[ $1 == "Size" ]]; then
		echo -e "Size:    \033[2m(map = 2D × 1.23, 3D: y = x × 0.93)\033[0m"
	elif [[ $1 == "Offset" || $1 == "View" ]]; then
		echo "$1:"
		for ((i=0; i<Total_figures; i++)); do
			[[ $1 == "Offset" ]] && B=${Hoffset[i]},${Voffset[i]} || B=${View[i]}
			[[ $B == "," ]] && B=""
			A=$A"—$(chr $((i+97)))—${1,,}=—\"${B:-¶}\""
		done
        align_parameters 3 $A
	fi
}

function set_index() {
	if [[ $1 == "on" ]]; then
		Index[${this:-0}]=${Index[${this:-0}]//🗙/}
	elif [[ $1 == "off" ]]; then
		Index[${this:-0}]="🗙${Index[${this:-0}]//🗙/}"
	elif [[ $1 == "{}" ]]; then
		unset Index[${this:-0}]
	elif [[ $1 != "" ]]; then
		Index[${this:-0}]=$1
	else
		echo "Index:"
		for ((i=0; i<Total_figures; i++)); do			
			L=$L"—$(chr $((i+97)))—index=—\"${Index[i]:-¶}\"—caption=—\"${Caption[i]:-¶}\"—position=—\"${Index_position[i]:-¶}\""
		done
        align_parameters 7 $L
	fi
}

function set_caption() {
	if [[ $1 == "{}" ]]; then
		unset Caption[${this:-0}]
	else
		Caption[${this:-0}]="■"$1
	fi
}

function set_key() {
	if [[ $1 == "{}" ]]; then
	    unset Key[${this:-0},${thisline:-1}]
	elif [[ $1 != "" ]]; then
		case $1 in
			vertical) 	Key_layout[${this:-0}]='vertical■maxcols■1';;
			horizontal) Key_layout[${this:-0}]='horizontal■maxrows■1';;
			*) 	Key[${this:-0},${thisline:-1}]=$1
				echo -e "    $(chr $((${this:-0}+97)))${thisline:-1}:  key= \"${Key[${this:-0},${thisline:-1}]}\"";;
		esac
	else
		echo "Key:"
		for ((i=0; i<Total_figures; i++)); do
            A=$A"—$(chr $((i+97)))—box-width=—\"${Key_box[i]:-¶}\"—box-position=—\"${Key_position[i]:-¶}\"—box-layout=—\"${Key_layout[i]:-¶}\""
			for ((j=1; j<=${Plot[i]:-1}; j++)); do
				L=$L"—$(chr $(($i+97)))$j—key=—\"${Key[$i,$j]:-¶}\""
                K=$K${Key[$i,$j]}
            done
        done
		if [[ $K ]]; then
			align_parameters 7 $A; echo; align_parameters 3 $L
		fi
	fi
}

function set_label() {
	if [[ $1 == "{}" ]]; then
		[[ ${Label[${this:-0},${thisline:-1}]} != "" ]] && ((Label[${this:-0}]--))
		unset Label[${this:-0},${thisline:-1}]
		[[ ${this:-0} > 0 && ${Label[${this:-0}]} == 0 ]] && unset Label[${this:-0}]
	elif [[ $1 != "" ]]; then
		[[ $((thisline-1)) > ${Label[$this]:-0} ]] && thisline=$((${Label[$this]:-0}+1))
        [[ ${Label[${this:-0},${thisline:-1}]} == "" ]] && ((Label[${this:-0}]++))
		Label[${this:-0},${thisline:-1}]=$1
		echo -e "    $(chr $((${this:-0}+97)))${thisline:-1}:  Label= \"${Label[${this:-0},${thisline:-1}]}\"  position= \"${Label_position[${this:-0},${thisline:-1}]}\""
	else
		echo "Label:"
		for ((i=0; i<Total_figures; i++)); do
			for ((j=1; j<=${Label[$i]:-0}; j++)); do
				A=$A"—$(chr $((i+97)))$j—label=—\"${Label[$i,$j]:-¶}\"—position=—\"${Label_position[$i,$j]:-¶}\""
				L=$L${Label[$i,$j]}
            done
        done
		[[ $L ]] && align_parameters 5 $A
	fi
}

function set_axis() {
	a=$3
    case $2 in
		l) 	name=label;;
		r) 	name=range;r1=${3%:*};r2=${3#*:};eval p="\${${1^}$name[${this:-0}]}";p1=${p%:*};p2=${p#*:}
			if [[ $3 == ":" ]]; then a="*:*"; else a=${r1:-${p1:-*}}:${r2:-${p2:-*}}; fi;;
		t) 	name=tics;;
		b)  name=box;;
	esac
	if [[ $3 == "{}" ]]; then
		unset ${1^}$name[${this:-0}]
		[[ $2 == "l" ]] && eval ${1^}$name[${this:-0}]="¶"
	elif [[ $3 != "" ]]; then
		eval ${1^}$name[${this:-0}]=\'$a\'
		echo -e "    $(chr $((${this:-0}+97))):  ${1^}$name= \"$a\""
	else
		echo "${1^}$name:"
		for ((i=0; i<Total_figures; i++)); do
			if [[ $2 == "t" ]]; then
				A=$A"—$(chr $((i+97)))—xtics=—\"${Xtics[i]:-¶}\"—ytics=—\"${Ytics[i]:-¶}\"—ztics=—\"${Ztics[i]:-¶}\"—ctics=—\"${Ctics[i]:-¶}\""
                NA=9
			elif [[ $2 == "b" ]]; then
				A=$A"—$(chr $((i+97)))—cb-layout=—\"${Cbox[i]:-¶}\"—ctics=—\"${Ctics[i]:-¶}\""
                NA=5
			fi
		done
        align_parameters $NA $A
	fi
}

function set_style() {
	c="${2//||/‖}";c="${c//_/■}"
	case $1 in
		u) name=Using;;
		w) name=With;;
		*) name=${1^};;
	esac
	if [[ $2 == "{}" ]]; then
        unset $name[${this:-0},${thisline:-1}]
	elif [[ $2 != "" ]]; then
		eval $name[${this:-0},${thisline:-1}]="\"${c//$/§}\""
		echo -e "    $(chr $((${this:-0}+97)))${thisline:-1}:  $name= \"$c\""
	else
        echo "Line Style:"
		for ((i=0; i<Total_figures; i++)); do
 			for ((j=1; j<=${Plot[i]:-1}; j++)); do
				L=$L"—$(chr $((i+97)))$j—with=—\"${With[$i,$j]:-¶}\"—dash=—\"${Dt[$i,$j]:-¶}\"—width=—\"${Lw[$i,$j]:-¶}\"—point=—\"${Pt[$i,$j]:-¶}\"—size=—\"${Ps[$i,$j]:-¶}\"—color=—\"${Lc[$i,$j]:-¶}\""
            done
        done
        align_parameters 13 $L
	fi
}

function set_line2line() {
    a1=$(($(ord ${1%%[0-9]*})-97)); b1=${1#[a-z]}
    a2=$(($(ord ${2%%[0-9]*})-97)); b2=${2#[a-z]}
	if [[ $a1 != $a2 ]]; then
		echo "Cannot $3 figure (${1%[0-9]*}) and figure (${2%[0-9]*})."
		exit
	fi
}

function swap_lines() {
    tmp=${Files[$a1,$1]}; Files[$a1,$1]=${Files[$a2,$2]}; Files[$a2,$2]=$tmp
    tmp=${Columns[$a1,$1]}; Columns[$a1,$1]=${Columns[$a2,$2]}; Columns[$a2,$2]=$tmp
    tmp=${Using[$a1,$1]}; Using[$a1,$1]=${Using[$a2,$2]}; Using[$a2,$2]=$tmp
    tmp=${With[$a1,$1]}; With[$a1,$1]=${With[$a2,$2]}; With[$a2,$2]=$tmp
    tmp=${Dt[$a1,$1]}; Dt[$a1,$1]=${Dt[$a2,$2]}; Dt[$a2,$2]=$tmp
    tmp=${Lw[$a1,$1]}; Lw[$a1,$1]=${Lw[$a2,$2]}; Lw[$a2,$2]=$tmp
    tmp=${Pt[$a1,$1]}; Pt[$a1,$1]=${Pt[$a2,$2]}; Pt[$a2,$2]=$tmp
    tmp=${Ps[$a1,$1]}; Ps[$a1,$1]=${Ps[$a2,$2]}; Ps[$a2,$2]=$tmp
    tmp=${Lc[$a1,$1]}; Lc[$a1,$1]=${Lc[$a2,$2]}; Lc[$a2,$2]=$tmp
    tmp=${Key[$a1,$1]}; Key[$a1,$1]=${Key[$a2,$2]}; Key[$a2,$2]=$tmp
}

function unset_empty_lines(){
	for key in ${!Files[*]}; do [[ ${Files[$key]} == "" ]] && unset Files[$key]; done
	for key in ${!Columns[*]}; do [[ ${Columns[$key]} == "" ]] && unset Columns[$key]; done
	for key in ${!Using[*]}; do [[ ${Using[$key]} == "" ]] && unset Using[$key]; done
	for key in ${!With[*]}; do [[ ${With[$key]} == "" ]] && unset With[$key]; done
	for key in ${!Dt[*]}; do [[ ${Dt[$key]} == "" ]] && unset Dt[$key]; done
	for key in ${!Lw[*]}; do [[ ${Lw[$key]} == "" ]] && unset Lw[$key]; done
	for key in ${!Pt[*]}; do [[ ${Pt[$key]} == "" ]] && unset Pt[$key]; done
	for key in ${!Ps[*]}; do [[ ${Ps[$key]} == "" ]] && unset Ps[$key]; done
	for key in ${!Lc[*]}; do [[ ${Lc[$key]} == "" ]] && unset Lc[$key]; done
	for key in ${!Key[*]}; do [[ ${Key[$key]} == "" ]] && unset Key[$key]; done
}

function set_swap() {
    set_line2line $1 $2 swap
	swap_lines $b1 $b2
	unset_empty_elements
}

function set_move() {
    set_line2line $1 $2 move
	if [ $b1 -gt $b2 ]; then
		for ((i=b1; i>b2; i--)); do swap_lines $i $((i-1)); done
	else
		for ((i=b1; i<b2; i++)); do swap_lines $i $((i+1)); done
	fi
	unset_empty_elements
}

function unset_select_line() {
	[[ ${Files[$1,$2]} ]] && Files[$1]=$((${Files[$1]:-1}-1))
	[[ ${Columns[$1,$2]} ]] && Columns[$1]=$((${Columns[$1]:-1}-1))
	Plot[$1]=$((${Plot[$1]:-1}-1))
	unset Files[$1,$2] Columns[$1,$2] Using[$1,$2] With[$1,$2] Dt[$1,$2] Lw[$1,$2] Pt[$1,$2] Ps[$1,$2] Lc[$1,$2] Key[$1,$2]
	for ((j=$2; j<${Plot[$1]}; j++)); do
		Files[$1,$j]=${Files[$1,$((j+1))]}; Files[$1,$((j+1))]=""
		Columns[$1,$j]=${Columns[$1,$((j+1))]}; Columns[$1,$((j+1))]=""
		Using[$1,$j]=${Using[$1,$((j+1))]}; Using[$1,$((j+1))]=""
		With[$1,$j]=${With[$1,$((j+1))]}; With[$1,$((j+1))]=""
		Dt[$1,$j]=${Dt[$1,$((j+1))]}; Dt[$1,$((j+1))]=""
		Lw[$1,$j]=${Lw[$1,$((j+1))]}; Lw[$1,$((j+1))]=""
		Pt[$1,$j]=${Pt[$1,$((j+1))]}; Pt[$1,$((j+1))]=""
		Ps[$1,$j]=${Ps[$1,$((j+1))]}; Ps[$1,$((j+1))]=""
		Lc[$1,$j]=${Lc[$1,$((j+1))]}; Lc[$1,$((j+1))]=""
		Key[$1,$j]=${Key[$1,$((j+1))]}; Key[$1,$((j+1))]=""
	done
}

function getclosestkey() {
    declare -n aa=$1
    if [[ ! $3 ]]; then
        for ((t=$2; t>=0; t--)); do [[ ${aa[t]} ]] && return; done; ((t++))
    else
		for ((s=$2; s>=0; s--)); do
			for ((t=$3; t>=1; t--)); do
				[[ ${aa[$s,$t]} ]] && return
			done
			[[ ${aa[$s,$t]} ]] && return
		done
        ((s++))
    fi
}

function make_table_axis() {
    getclosestkey Graph $1; gr=${Graph[$1]:-${Graph[t]:-2d}}
    getclosestkey Xsize $1; xs=${Xsize[$1]:-${Xsize[t]}}
    getclosestkey Ysize $1; ys=${Ysize[$1]:-${Ysize[t]}}
    if [[ $1 == 0 ]]; then
        Index[0]=${Index[0]:-'(a)'}
        a1=$(ord ${Index[0]//[^A-Za-z]/})
    fi
	if [[ ${Index[n]} == "" ]]; then
		getclosestkey Index $1; index=${Index[$1]:-${Index[t]}}
		index=${index/[A-Za-z]/$(chr $((a1+$1)))}${Caption[$1]}
	else
		index=${Index[$1]}${Caption[$1]}
	fi
	getclosestkey Xlabel $1; xl=${Xlabel[$1]:-${Xlabel[t]:-¶}}
	getclosestkey Ylabel $1; yl=${Ylabel[$1]:-${Ylabel[t]:-¶}}
	getclosestkey Zlabel $1; zl=${Zlabel[$1]:-${Zlabel[t]:-¶}}
	getclosestkey Xrange $1; xr=${Xrange[$1]:-${Xrange[t]:-*:*}}
	getclosestkey Yrange $1; yr=${Yrange[$1]:-${Yrange[t]:-*:*}}
	getclosestkey Zrange $1; zr=${Zrange[$1]:-${Zrange[t]:-*:*}}
	getclosestkey Crange $1; cr=${Crange[$1]:-${Crange[t]:-*:*}}
	getclosestkey Xtics $1; xt=${Xtics[$1]:-${Xtics[t]:-auto}}
	getclosestkey Ytics $1; yt=${Ytics[$1]:-${Ytics[t]:-auto}}
	getclosestkey Ztics $1; zt=${Ztics[$1]:-${Ztics[t]:-auto}}
	getclosestkey Ctics $1; ct=${Ctics[$1]:-${Ctics[t]:-auto}}
}

function make_table_line_style() {
    [[ $gr == "2d" ]] && pl=plot || pl=splot
	getclosestkey Using $1 $2; uc=${Using[$1,$2]:-${Using[$s,$t]:-1:c}}
	getclosestkey With $1 $2; ws=${With[$1,$2]:-${With[$s,$t]:-l}}
	getclosestkey Dt $1 $2; dt=${Dt[$1,$2]:-${Dt[$s,$t]:-1}}
	getclosestkey Lw $1 $2; lw=${Lw[$1,$2]:-${Lw[$s,$t]:-2}}
	getclosestkey Pt $1 $2; pt=${Pt[$1,$2]:-${Pt[$s,$t]:-7}}
	getclosestkey Ps $1 $2; ps=${Ps[$1,$2]:-${Ps[$s,$t]:-0.5}}
	getclosestkey Lc $1 $2; lc=${Lc[$1,$2]:-${Lc[$s,$t]:-c}}
	u=${u//§/$}
	[[ $lc =~ "#" ]] && lc=${lc^^}
}

function make_table() {
	rm -f .me/table
	touch .me/table
	if [[ $Merge == "f" ]]
    then L1=${Columns["N"]}; L2=${Files["N"]}
    else L1=${Files["N"]}; L2=${Columns["N"]}
    fi
 	for ((i=0; i<L1; i++)); do
		for ((j=0; j<L2; j++)); do
			case $Merge in
				0) n=$((i*L2+j)); k=1;;
				c) n=$i; k=$((j+1));;
				f) n=$i; k=$((j+1));;
				a) n=0; k=$((i*L2+j+1));;
			esac
			make_table_axis $n
			if [[ ${Columns[$n]:-0} == 0 && ${Files[$n]:-0} == 0 ]]; then
				if [[ $Merge == "f" ]]; then df=${Files[$j,0]}; else df=${Files[$i,0]}; fi
				getclosestkey Columns $j 0; col=${Columns[$j,0]:-${Columns[$s,0]}}
				make_table_line_style $n $k
				echo $n $k $index $pl $df ${uc/c/$col} $ws $dt $lw $pt $ps ${lc/c/$((k+5))} \"${Key[$n,$k]}\" $xl $xr $xt $yl $yr $yt $zl $zr $zt $cr $ct $gr $xs $ys>> .me/table
			elif [[ ${Columns[$n]:-0} > 0 && ${Files[$n]:-0} == 0 ]]; then
				for ((k=1; k<=${Columns[$n]}; k++)); do
					getclosestkey Columns $n $k; col=${Columns[$n,$k]:-${Columns[$s,$t]}}
					make_table_line_style $n $k
					echo $n $k $index $pl ${Files[$n,0]} ${uc/c/$col} $ws $dt $lw $pt $ps ${lc/c/$((k+5))} \"${Key[$n,$k]}\" $xl $xr $xt $yl $yr $yt $zl $zr $zt $cr $ct $gr $xs $ys >> .me/table
				done
				((k--))
			elif [[ ${Columns[$n]:-0} == 0 && ${Files[$n]:-0} > 0 ]]; then
				getclosestkey Columns $n 0; col=${Columns[$n,0]:-${Columns[$s,0]}}
				for ((k=1; k<=${Files[$n]}; k++)); do
					make_table_line_style $n $k
					echo $n $k $index $pl ${Files[$n,$k]} ${uc/c/$col} $ws $dt $lw $pt $ps ${lc/c/$((k+5))} \"${Key[$n,$k]}\" $xl $xr $xt $yl $yr $yt $zl $zr $zt $cr $ct $gr $xs $ys >> .me/table
				done
				((k--))
			else
				if [[ $Merge == "c" ]]
				then N1=${Columns[$n]}; N2=${Files[$n]}
				else N1=${Files[$n]}; N2=${Columns[$n]}
				fi
				for ((l=1; l<=N1; l++)); do
					for ((m=1; m<=N2; m++)); do
						if [[ $Merge == "c" ]]; then df=${Files[$n,$m]}; p=$l; else df=${Files[$n,$l]}; p=$m; fi
						getclosestkey Columns $n $p; col=${Columns[$n,$p]:-${Columns[$s,$t]}}
						k=$(((l-1)*N2+m))
						make_table_line_style $n $k
						echo $n $k $index $pl $df ${uc/c/$col} $ws $dt $lw $pt $ps ${lc/c/$((k+5))} \"${Key[$n,$k]}\" $xl $xr $xt $yl $yr $yt $zl $zr $zt $cr $ct $gr $xs $ys >> .me/table
					done
				done
			fi
            Plot[$n]=$k
		done
	done
	Total_figures=$((n+1))
}

function make_layout() {
	if [ $Total_figures -gt 1 ]; then
		Layout=($(awk -v N=$Total_figures -v A=${Align[1]} '
		BEGIN {
			if (N < A) {
				Xdim = N
			} else {
				Xdim = A
			}
			if (N % Xdim) {
				Ydim = int(N/Xdim) + 1
			} else {
				Ydim = int(N/Xdim)
			}
			print Xdim, Ydim
		}'))
		n=0
		if [ ${Align[0]} == "Z" ]; then
			for ((y=0; y<${Layout[1]}; y++)); do
				for ((x=0; x<${Layout[0]}; x++)); do
					Xsite[$n]=$x
					Ysite[$n]=$y
					((n++))
					[ $n -ge $Total_figures ] && break
				done
				[ $n -ge $Total_figures ] && break
			done
		else
			for ((x=0; x<${Layout[0]}; x++)); do
				for ((y=0; y<${Layout[1]}; y++)); do
					Xsite[$n]=$x
					Ysite[$n]=$y
					((n++))
					[ $n -ge $Total_figures ] && break
				done
				[ $n -ge $Total_figures ] && break
			done
		fi
	else
		Layout=(1 1)
		Xsite=(0)
		Ysite=(0)
	fi
}

datafile=()
skipupdate=0

function next() {
	drop+=($n)
    for ((j=1; j<${1:-0}; j++));do ((n++));drop+=($n);done
}

#<-- Parameters : Table -->
for ((n=0; n<${#Arg[*]}; n++)); do
	if [ -e ${Arg[$n]} ]; then
		[[ ${Arg[$n]#*.} == "gp" || ${Arg[$n]#*.} == "pdf" || ${Arg[$n]#*.} == "eps" || ${Arg[$n]#*.} == "zip" ]] && continue
        datafile+=(${Arg[$n]});next;continue
	elif [ "${Arg[$n]//[:,0-9]/}" == "[]" ]; then
		get_column ${Arg[$n]};next;continue
	elif [[ $this && $thisline && ${Arg[$n]} == "{}" ]]; then
		unset_select_line $this $thisline
		unset_empty_lines;next;continue
	fi
	case ${Arg[$n]} in
		-m[0acf]) Merge=${Arg[$n]:2:1};next;continue;;
		-[NZ][1-9])	Align=(${Arg[$n]:1:1} ${Arg[$n]:2:1});next;continue;;
		-[a-p]|-[a-p][1-9]|-[a-p][1-9][0-9]) choose ${Arg[$n]#-};next;continue;;
		-graph) set_graph ${Arg[$n+1]};next 2;continue;;
		-space)	set_csparameters Space ${Arg[$n+1]};next 2;continue;;
		-size)	set_csparameters Size ${Arg[$n+1]};next 2;continue;;
		-I)  set_index ${Arg[$n+1]};next 2;continue;;
		-ic) set_caption ${Arg[$n+1]};next 2;continue;;
		-K)  set_key ${Arg[$n+1]};next 2;continue;;
		-L)  set_label ${Arg[$n+1]};next 2;continue;;
		-[cxyz][blrt]) set_axis ${Arg[$n]:1:1} ${Arg[$n]:2:1} ${Arg[$n+1]};next 2;continue;;
		-u|-w|-dt|-lw|-pt|-ps|-lc) set_style ${Arg[$n]#-} ${Arg[$n+1]};next 2;continue;;
        -swap) set_swap ${Arg[$n+1]} ${Arg[$n+2]};next 3;continue;;
        -move) set_move ${Arg[$n+1]} ${Arg[$n+2]};next 3;continue;;
		-tra) skipupdate=1;continue;;
		-cal) skipupdate=1;continue;;
		-der) skipupdate=1;continue;;
		-int) skipupdate=1;continue;;
		-fft) skipupdate=1;continue;;
	esac
done

if [[ ${#drop[*]} > 0 ]]; then
    if [[ ${#datafile[*]} -gt 0 && $skipupdate == 0 ]]; then
        get_file
    fi
	if [ ${Files["N"]:-0} -gt 0 ]; then
		make_table
		make_layout
	fi
	issave=1
fi

#-========-========-======-==-=======-=======-====-=========-======---===-==-

function set_page() {
	case ${1,,} in
		portrait)  Page="portrait";  Pagewidth=21.0; Pageheight=29.7;;
		landscape) Page="landscape"; Pagewidth=29.7; Pageheight=21.0;;
		square)    Page="landscape"; Pagewidth=29.7; Pageheight=29.7;;
	esac
	Wpt=$(awk "BEGIN {printf \"%.0f\", $Pagewidth*$Dpi/2.54}")
	Hpt=$(awk "BEGIN {printf \"%.0f\", $Pageheight*$Dpi/2.54}")
	echo "A4 $Page size: $Wpt pt x $Hpt pt"
}

function set_font() {
	f1=${1%,*}
	f2=${1#*,}
	case ${f1,,} in
		cm) if [[ $(grep -c '<dir>~/bin/.fonts</dir>' /etc/fonts/fonts.conf) == 0 ]]; then
				sudo sed -i '/<dir>~\/bin\/.fonts<\/dir>/d;30a\        <dir>~/bin/.fonts</dir>' /etc/fonts/fonts.conf
			fi
			if [[ $(ls ~/bin/.fonts/ | grep -c ttf) == 0 ]]; then
				echo -n "Download Computer-Modern True-Type Fonts"
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmr10.ttf -P ~/bin/.fonts/;echo -n "."
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmti10.ttf -P ~/bin/.fonts/;echo -n "."
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmmi10.ttf -P ~/bin/.fonts/;echo -n "."
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmb10.ttf -P ~/bin/.fonts/;echo -n "."
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmbxti10.ttf -P ~/bin/.fonts/;echo -n "."
				wget -q http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmsy10.ttf -P ~/bin/.fonts/;echo "."
			fi
			Labelmargin=1.25
			Font=cmr10;;
		arial) Labelmargin=1.0
			   Font=Arial;;
		times) Labelmargin=1.0
			   Font=Times;;
	esac
	[[ $f2 != "" && ${f2//[0-9]/} == "" ]] && Fontsize=$f2
}

function set_position() {
	if [[ $1 == "Key" ]]; then
		[[ ${Key_box[${this:-0}]} == "off" ]] && py=1.0 || py="*$Keymargin"
	else
		py="*$Labelmargin"
	fi
	if [[ ${Graph[${this:-0}]} != "3d" ]]; then
		case $2 in
			sh) pos="-XC*5,1+YC$py,left";;
			hl) pos="XC,1+YC$py,left";;
			h)  pos="0.5,1+YC$py,center";;
			hr) pos="1-XC,1+YC$py,right";;
			tl) pos="XC,1-YC$py,left";;
			t)  pos="0.5,1-YC$py,center";;
			tr) pos="1-XC,1-YC$py,right";;
			to) pos="1+XC,1-YC$py,left";;
			l)  pos="XC,0.5,left";;
			c)  pos="0.5,0.5,center";;
			r)  pos="1-XC,0.5,right";;
			o)  pos="1+XC,0.5,left";;
			bl) pos="XC,YC$py,left";;
			b)  pos="0.5,YC$py,center";;
			br) pos="1-XC,YC$py,right";;
			bo) pos="1+XC,YC$py,left";;
			*) 	[[ ${2//[^,]/} == "," ]] && pos=$2",left" || pos=$2;;
		esac
	else
		[[ ${2//[^,]/} == ",," ]] && pos=$2",left" || pos=$2
	fi
	if [[ $pos == "{}" ]]; then
		case $1 in
			Index) unset Index_position[${this:-0}];;
			Label) unset Label_position[${this:-0},${thisline:-1}];;
			Key) unset Key_position[${this:-0}];;
		esac
	elif [[ $pos == "" ]]; then
		echo "me -${1:0:1}"
	else
		case $1 in
			Index) Index_position[${this:-0}]=${pos//,,/,left,}
				   echo -e "    $(chr $((${this:-0}+97))):  Index= \"${Index[${this:-0}]}\"  position= \"${Index_position[${this:-0}]}\"";;
			Label) Label_position[${this:-0},${thisline:-1}]=${pos//,,/,left,}
				   echo -e "    $(chr $((${this:-0}+97)))${thisline:-1}:  Label= \"${Label[${this:-0},${thisline:-1}]}\"  position= \"${Label_position[${this:-0},${thisline:-1}]}\"";;
			Key)   Key_position[${this:-0}]=${pos//,,/,left,}
				   echo -e "    $(chr $((${this:-0}+97))):  Key box= \"${Key_box[${this:-0}]}\"  position= \"${Key_position[${this:-0}]}\"";;
		esac
	fi
}

function gpscript_palette() {
	HEAT="defined (0 '#000090', 1 '#000fff', 2 '#0090ff', 3 '#0fffee', 4 '#ffffff', 5 '#ffee00', 6 '#ff7000', 7 '#ee0000', 8 '#7f0000')"
	JET="defined (0 '#000090', 1 '#000fff', 2 '#0090ff', 3 '#0fffee', 4 '#90ff70', 5 '#ffee00', 6 '#ff7000', 7 '#ee0000', 8 '#7f0000')"
	PARULA="defined (0 '#352a87', 1 '#2053d4', 2 '#0d75dc', 3 '#0c93d2', 4 '#07a9c2', 5 '#38b99e', 6 '#7cbf7b', 7 '#b7bd64', 8 '#f1b94a', 9 '#fad32a', 10 '#f9fb0e')"
	VIRIDIS="viridis"
	GREEN="defined (0 '#005A32', 1 '#238B45', 2 '#41AB5D', 3 '#74C476', 4 '#A1D99B', 5 '#C7E9C0', 6 '#E5F5E0', 7 '#F7FCF5')"
	GREY="defined (0 '#252525', 1 '#525252', 2 '#737373', 3 '#969696', 4 '#bdbdbd', 5 '#d9d9d9', 6 '#f0f0f0', 7 '#ffffff')"
    palette=$(eval echo \$$1)
}

function set_3dparameters() {
	if [[ $2 != "" ]]; then
		case ${2,,} in
			on|off) eval $1[${this:-0}]=${2,,};;
			{}) unset $1[${this:-0}];;
			*) if [[ $1 == "Pm3d" ]]; then
                   gpscript_palette ${2^^}
                   if [[ $palette == "" ]]; then
                       echo "Unknown parameter: $1"
                       exit
                   fi
                   Palette[${this:-0}]=${2^^}
               fi;;
		esac
		echo "    $(chr $((${this:-0}+97))):  pm3d= \"${Pm3d[${this:-0}]}\"  palette= \"${Palette[${this:-0}]}\"  axis3d= \"${Axis3d[${this:-0}]}\""
	else
        echo "Pm3d:"
		for ((i=0; i<Total_figures; i++)); do
			A=$A"—$(chr $((i+97)))—pm3d=—\"${Pm3d[i]:-¶}\"—palette=—\"${Palette[i]:-¶}\"—axis3d=—\"${Axis3d[i]:-¶}\""
		done
        align_parameters 7 $A
	fi
}

#<-- Drop 1st-level parameters -->
for ((n=0; n<${#drop[*]}; n++)); do
	unset Arg[${drop[$n]}]
done

Arg=(${Arg[*]})
drop=()

#<-- Parameters : Script -->
for ((n=0; n<${#Arg[*]}; n++)); do
	case ${Arg[$n]} in
    	-O)	    Output="${Arg[$n+1]}";next 2;continue;;
		-fs)	FS="${Arg[$n+1]:- }";next 2;continue;;
		-page)	set_page ${Arg[$n+1]};next 2;continue;;
		-font)	set_font ${Arg[$n+1]};next 2;continue;;
		-offset)set_csparameters Offset ${Arg[$n+1]};next 2;continue;;
		-ip)	set_position Index ${Arg[$n+1]};next 2;continue;;
		-lp)	set_position Label ${Arg[$n+1]};next 2;continue;;
		-kp)	set_position Key ${Arg[$n+1]};next 2;continue;;
		-kb) 	Key_box[${this:-0}]=${Arg[$n+1]:-off};next 2;continue;;
		-view)  set_csparameters View ${Arg[$n+1]};next 2;continue;;
		-pm3d)	set_3dparameters Pm3d ${Arg[$n+1]};next 2;continue;;
        -axis3d)set_3dparameters Axis3d ${Arg[$n+1]};next 2;continue;;
		-bz) BZoffset[0]=${Arg[$n+1]%,*};BZoffset[1]=${Arg[$n+1]#*,};next 2;continue;;
	esac
done

[[ $issave -eq 1 || ${#drop[*]} -gt 0 ]] && save_parameters

#-========-========-======-==-=======-=======-====-=========-======---===-==-

function gnuplot_show_variables() {
	echo -e "set terminal unknown\nset datafile separator $separator" > .me/gp
	awk -v xsite="${Xsite[*]}" -v ysite="${Ysite[*]}" -v plot="${Plot[*]}" '
    BEGIN {split(xsite,ix," "); split(ysite,iy," "); split(plot,Plot," ")}
	{Data[NR] = $0}
	END { k = 1
        for (i=1; i<=length(Plot); i++) {
            for (j=1; j<=Plot[i]; j++) {
                split(Data[k], c, " ")
                split(c[6], u, "■")
                gsub("§", "$", u[1])
                gsub("‖", "||", u[1])
                if (c[2] == 1) {
                    printf "%s [%s] [%s] [%s] \"%s\" u %s t \"ix= %d iy= %d Graph= %d Xsize= %f Ysize= %f xl= %s yl= %s zl= %s xt= %f yt= %f zt= %f ct= %f \"", c[4], c[15], c[18], c[21], c[5], u[1], ix[i], iy[i], c[25], c[26], c[27], c[14], c[17], c[20], c[16], c[19], c[22], c[24]
                } else {
                    printf " \"%s\" u %s", c[5], u[1]
                }
                if (j < Plot[i]) {printf " ,\\\n"} else {printf "\n"}
                k ++
            }
            print "show variables all"
        }
	}' .me/table >> .me/gp
}

function gnuplot_gpval() {
    GPV_str=$(awk -v Total_figures=$Total_figures '
    function ticstep(max, min) {
		xr = max - min; xr = (xr<0 ? -xr : xr)
		power = 10.0 ** int(log(xr)/log(10))
		xnorm = xr / power
		posns = 20.0 / xnorm
		if (posns > 40) {tics = 0.05}
		else if (posns > 20 ) {tics = 0.1}
		else if (posns > 10 ) {tics = 0.2}
		else if (posns > 4  ) {tics = 0.5}
		else if (posns > 2  ) {tics = 1  }
		else if (posns > 0.5) {tics = 2  }
		else {tics = int(xnorm)+1}
		return (tics*power)
    }
    function ticlength(max, min, interval) {
        if (interval == "single") {tic = max}
        else {
            if (interval == 0) interval = ticstep(max, min)
            max_minus = max - interval
            min_plus = min + interval
            tic = length(max_minus) > length(max) ? max_minus : max
            if (length(min_plus) > length(tic)) tic = min_plus
            if (length(min) > length(tic)) tic = min
        }
        t_minus = gsub(/-/, "", tic)*0.67
        t_dot = gsub(/\./, "", tic)*0.5
        return (length(tic) + t_minus + t_dot)
    }
	{
		gsub(/\.0$/,"",$3)
		switch ($1) {
			case "GPVAL_LAST_PLOT":
				Nx = $12
				Ny = $14
                Graph[Nx][Ny] = $16; Total_graph += $16
				gsub(/0+$/,"",$18); gsub(/\.$/,"",$18); Xsize[Nx][Ny] = $18; XSnum[$18]++
				gsub(/0+$/,"",$20); gsub(/\.$/,"",$20); Ysize[Nx][Ny] = $20; YSnum[$20]++
				dy[Nx][Ny] = $22 ~ /\^/ ? -0.5 : 0    # Xlabel
				dx[Nx][Ny] = $24 ~ /_/  ? -0.5 : 0    # Ylabel
                Xtics[Nx][Ny] = $28
                Ytics[Nx][Ny] = $30
                Ztics[Nx][Ny] = $32
                Ctics[Nx][Ny] = $34
				break
			case "GPVAL_X_MIN":
				Xmin[Nx][Ny] = $3
				break
			case "GPVAL_X_MAX":
				Xmax[Nx][Ny] = $3
				break
			case "GPVAL_DATA_X_MIN":
				DXmin[Nx][Ny] = $3
				break
			case "GPVAL_DATA_X_MAX":
				DXmax[Nx][Ny] = $3
				break
			case "GPVAL_Y_MIN":
				Ymin[Nx][Ny] = $3
				break
			case "GPVAL_Y_MAX":
				Ymax[Nx][Ny] = $3
				break
			case "GPVAL_DATA_Y_MIN":
				DYmin[Nx][Ny] = $3
				break
			case "GPVAL_DATA_Y_MAX":
				DYmax[Nx][Ny] = $3
				break
			case "GPVAL_Z_MIN":
				Zmin[Nx][Ny] = $3
				break
			case "GPVAL_Z_MAX":
				Zmax[Nx][Ny] = $3
				break
			case "GPVAL_DATA_CB_MIN":
				Cmin[Nx][Ny] = $3
				break
			case "GPVAL_DATA_CB_MAX":
				Cmax[Nx][Ny] = $3
				break        
		}
	}
    END {
        Avg_graph = Total_graph / Total_figures
        for (j=0; j<=Ny; j++) {
            for (i=0; i<=Nx; i++) {
				if (Graph[i][j] == 3) {
					xsizemax3 = xsizemax3 < Xsize[i][j] ? Xsize[i][j] : xsizemax3
					ysizemax3 = ysizemax3 < Ysize[i][j] ? Ysize[i][j] : ysizemax3
					lxt[i] = ticlength(Xmax[i][j], Xmin[i][j], Xtics[i][j])
					lyt[i] = ticlength(Ymax[i][j], Ymin[i][j], Ytics[i][j])
					lzt[i] = ticlength(Zmax[i][j], Zmin[i][j], Ztics[i][j])
					print "["i","j",xmin]="Xmin[i][j], "["i","j",xmax]="Xmax[i][j], "["i","j",ymin]="Ymin[i][j], "["i","j",ymax]="Ymax[i][j], "["i","j",zmin]="Zmin[i][j], "["i","j",zmax]="Zmax[i][j], "["i","j",xr]="Xmin[i][j]":"Xmax[i][j], "["i","j",yr]="Ymin[i][j]":"Ymax[i][j], "["i","j",zr]="Zmin[i][j]":"Zmax[i][j], "["i","j",lxt]="lxt[i], "["i","j",lyt]="lyt[i], "["i","j",zlp]="lzt[i]+2
				} else if (Graph[i][j] == 2) {
					if (XSnum[Xsize[i][j]] == Total_figures || XSnum[Xsize[i][j]] > 1) {xsizemax2 = xsizemax2 < Xsize[i][j] ? Xsize[i][j] : xsizemax2}
					if (YSnum[Ysize[i][j]] == Total_figures || YSnum[Ysize[i][j]] > 1) {ysizemax2 = ysizemax2 < Ysize[i][j] ? Ysize[i][j] : ysizemax2}
					lxt[i] = ticlength(Xmax[i][j], Xmin[i][j], "single")
					lyt[i] = ticlength(Ymax[i][j], Ymin[i][j], Ytics[i][j])
					print "["i","j",xmin]="Xmin[i][j], "["i","j",xmax]="Xmax[i][j], "["i","j",ymin]="Ymin[i][j], "["i","j",ymax]="Ymax[i][j], "["i","j",xr]="Xmin[i][j]":"Xmax[i][j], "["i","j",yr]="Ymin[i][j]":"Ymax[i][j],  "["i","j",ylp]="lyt[i]+dx[i][j]-2, "["i","j",xlp]="0.25+dy[i][j]
				} else {
					xsizemax0 = xsizemax0 < Xsize[i][j] ? Xsize[i][j] : xsizemax0
					ysizemax0 = ysizemax0 < Ysize[i][j] ? Ysize[i][j] : ysizemax0
					lxt[i] = ticlength(DXmax[i][j], DXmin[i][j], "single")
					lyt[i] = ticlength(DYmax[i][j], DYmin[i][j], Ytics[i][j])
					lct[i] = ticlength(Cmax[i][j],  Cmin[i][j],  Ctics[i][j])
					print "["i","j",xmin]="DXmin[i][j], "["i","j",xmax]="DXmax[i][j], "["i","j",ymin]="DYmin[i][j], "["i","j",ymax]="DYmax[i][j], "["i","j",cmin]="Cmin[i][j], "["i","j",cmax]="Cmax[i][j], "["i","j",xr]="DXmin[i][j]":"DXmax[i][j], "["i","j",yr]="DYmin[i][j]":"DYmax[i][j], "["i","j",cr]="Cmin[i][j]":"Cmax[i][j], "["i","j",ylp]="lyt[i]-2, "["i","j",xlp]="0.25+dy[i][j]
				}
                if (i > 0) {
                    if (Avg_graph == 3) {
                        hspace = hspace < lzt[i] ? lzt[i] : hspace
                    } else {
						hspace = hspace < lyt[i]+lxt[i-1]*0.5 ? lyt[i]+lxt[i-1]*0.5 : hspace
                    }
                }
            }
        }
		if (Avg_graph == 3) {
			margin = margin < lzt[0] ? lzt[0] : margin
			xsizemax = xsizemax3
			ysizemax = ysizemax3
		} else {
			margin = margin < lyt[0]-lxt[Nx]*0.5 ? lyt[0]-lxt[Nx]*0.5 : margin
			if (Avg_graph == 0) {
				xsizemax = xsizemax0
				ysizemax = ysizemax0
			} else {
				xsizemax = xsizemax2
				ysizemax = ysizemax2			
			}
		}
		print "[hspace]="hspace+3, "[margin]="margin+1, "[xsizemax]="xsizemax, "[ysizemax]="ysizemax
	}' .me/gpval)
}

function gpscript_head() {
	Wpt=$(awk "BEGIN {printf \"%.0f\", $Pagewidth*$Dpi/2.54}")
	Hpt=$(awk "BEGIN {printf \"%.0f\", $Pageheight*$Dpi/2.54}")
	[[ $Hspace == "*" ]] && hspace=${GPV[hspace]} || hspace=$Hspace
	[[ $Vspace == "*" ]] && vspace=6 || vspace=$Vspace
	[[ $Hspace == "*" || $Vspace == "*" ]] && echo "    Space=（$hspace,$vspace）"
	xspace=$(awk "BEGIN {printf \"%.2f\", ($hspace*(${Layout[0]}-1)-${GPV[margin]})*$Digitscale}")
	yspace=$(awk "BEGIN {printf \"%.2f\",  $vspace*(${Layout[0]}-1)+3}")
	echo "#<-- Figure head -->
X_ORIGIN = 0.5*($Wpt - ${GPV[xsizemax]}*${Layout[0]} - $Fontsize*($xspace))/$Wpt.0
Y_ORIGIN = 0.5*($Hpt + ${GPV[ysizemax]}*(${Layout[1]}-2) + $Fontsize*$yspace)/$Hpt.0
X_OFFSET = (${GPV[xsizemax]} + $Fontsize*$hspace)/$Wpt.0
Y_OFFSET = (${GPV[ysizemax]} + $Fontsize*$vspace)/$Hpt.0

set datafile separator $separator
set encoding iso_8859_1
set terminal pdfcairo color enhanced font \"${Font},$Fontsize\" size ${Pagewidth}cm,${Pageheight}cm fontscale 0.75
set output \"$Output.pdf\"
set margins 0,0,0,0
set multiplot" > .me/gp
}

function gpscript_set_origin() {
	Hoffset[$1]=${Hoffset[$1]:-${Hoffset[$1-1]}}
	Voffset[$1]=${Voffset[$1]:-${Voffset[$1-1]}}
	[[ ${Hoffset[$1]} == "" || ${Hoffset[$1]} == "0" ]] && hoffset="" || hoffset="+("${Hoffset[$1]}"/$Wpt.0)"
	[[ ${Voffset[$1]} == "" || ${Voffset[$1]} == "0" ]] && voffset="" || voffset="+("${Voffset[$1]}"/$Hpt.0)"
    Xsize[$1]=${Xsize[$1]:-${Xsize[$1-1]:-${Xsize[0]}}}
    Ysize[$1]=${Ysize[$1]:-${Ysize[$1-1]:-${Ysize[0]}}}
	if [[ ${Graph[$1]} == "3d" ]]; then
		Fontset="font \",$(awk "BEGIN {print $Fontsize-2}")\""
	else
		Fontset=""
	fi
    if [[ $1 == 0 ]]; then
        Index[0]=${Index[0]:-'(a)'}
        a1=$(ord ${Index[0]//[^A-Za-z]/})
    fi
	if [[ ${Index[$1]} == "" ]]; then
        Index[$1]=${Index[$1]:-${Index[$1-1]:-${Index[0]}}}
        index=${Index[$1]/[A-Za-z]/$(chr $((a1+$1)))}${Caption[$1]//■/ }
	else
		index=${Index[$1]}${Caption[$1]//■/ }
	fi
	Index_position[$1]=${Index_position[$1]:-${Index_position[$1-1]:-auto}}
	if [[ ${Index_position[$1]} == "auto" ]]; then
		case ${Graph[$1]} in
			2d) p1="XC,1-YC*$Labelmargin,left";;
			3d) yoffset=$(awk "BEGIN {printf \"%.2f\", 1.6*cos($Vx*0.0174533)*cos($Vz*0.0174533) }")
				p1="-XC,-XC,1+YC+$yoffset,left";;
		   map) p1="XC,1+YC*$Labelmargin,left";;
		esac
	else
		p1=${Index_position[$1]}
	fi
	echo "XC = $Fontsize*$Digitscale/${Xsize[$1]}; YC = $Fontsize*1.00/${Ysize[$1]}
set origin X_ORIGIN+X_OFFSET*$ix$hoffset,Y_ORIGIN-Y_OFFSET*$iy$voffset
set size noratio ${Xsize[$1]}/$Wpt.0,${Ysize[$1]}/$Hpt.0
set border 31
unset label; unset arrow; unset key; unset grid; unset xlabel; unset ylabel">> .me/gp
	if [[ ${index:0:1} != "🗙" ]]; then
		echo "set label 1 \"${index% }\" at graph ${p1%,*} ${p1##*,} front" >> .me/gp
	fi
    for ((j=1; j<=${Label[$1]:-0}; j++)); do
        p2=${Label_position[$1,$j]:-${Label_position[0,1]}}
		fs=${p2##*,}
		if [[ ${fs//[0-9]/} == "" ]]; then
			Usrfontset="font \",$fs\""
			p2=${p2%,*}
		fi
		[[ ${Graph[$1]} == "map" ]] && textcolor="tc lt 5 " || textcolor=""
        echo "set label $((j+1)) \"${Label[$1,$j]}\" at graph ${p2%,*} ${p2##*,} ${textcolor}front $Usrfontset" >> .me/gp
    done
	if ! [[ ${#Key[*]} == 1 && ${Key[0,1]} == "" ]]; then
		Key_position[$1]=${Key_position[$1]:-${Key_position[$1-1]:-auto}}
		if [[ ${Key_position[$1]} == "auto" ]]; then
			p3="1-XC,1-YC*$Keymargin,right"
		else
			p3=${Key_position[$1]}
		fi		
		echo "set key at graph ${p3%,*} ${p3##*,} ${Key_layout[$1]:-${Key_layout[0]}} Left reverse samplen 1 spacing 1.5 noautotitle font \",$(awk "BEGIN {print $Fontsize-2}")\"" >> .me/gp
		Key_box[$1]=${Key_box[$1]:-${Key_box[$1-1]}}
		Key_box[$1]=${Key_box[$1]//on/0}
		if [[ ${Key_box[$1]} == "off" ]]; then
			echo "set key nobox" >> .me/gp
		else
			echo "set key box lw 0.5 width ${Key_box[$1]} height 0.25" >> .me/gp
		fi
	fi
}

function gpscript_set_axis() {
	ex=$((${Layout[0]}-1))
	ey=$((${Layout[1]}-1))
	Xlabel[$1]=${Xlabel[$1]:-${Xlabel[$1-1]:-¶}}
	Ylabel[$1]=${Ylabel[$1]:-${Ylabel[$1-1]:-¶}}
	xl=${Xlabel[$1]}
	yl=${Ylabel[$1]}
    Xtics[$1]=${Xtics[$1]:-${Xtics[$1-1]:-auto}}
    Ytics[$1]=${Ytics[$1]:-${Ytics[$1-1]:-auto}}
	xt=${Xtics[$1]}
	yt=${Ytics[$1]}
	case ${Graph[$1]} in
		2d)	xl_pos="0,"$(awk "BEGIN {printf \"%.2f\", ${GPV[$ix,$iy,xlp]}}")"■center"
			yl_pos=$(awk "BEGIN {printf \"%.2f\", ${GPV[$ix,$iy,ylp]}*$Digitscale}")",0■center"
			xt_pos="0,0.25"
			yt_pos="0.25,0"
			vs1=4.01; hs1=$(awk "BEGIN {printf \"%.2f\", ${GPV[hspace]}-1}");;
		3d) Lxt=$(awk "BEGIN {printf \"%.2f\", (${GPV[$ix,$iy,lxt]}+2)*$Digitscale}")
            Lyt=$(awk "BEGIN {printf \"%.2f\", (${GPV[$ix,$iy,lyt]}+2)*$Digitscale}")
			Xrotation=$(awk "BEGIN {printf \"%.2f\", cos($Vx*0.0174533)*cos($Vz*0.0174533)}")
			Yrotation=$(awk "BEGIN {printf \"%.2f\", sin($Vx*0.0174533)*cos($Vz*0.0174533)}")
            xl_pos=$(awk "BEGIN {printf \"%.2f,%.2f\",  $Lxt*$Xrotation,-$Lxt*$Yrotation*0.25}")",0■left"
			yl_pos=$(awk "BEGIN {printf \"%.2f,%.2f\", -$Lyt*$Xrotation,-$Lyt*$Yrotation*0.25}")",0■right"
			xt_pos=$(awk "BEGIN {printf \"%.2f,%.2f\", 1.5*$Xrotation,-0.25*$Yrotation}")",0"
            yt_pos="0,"$(awk "BEGIN {printf \"%.2f\", -0.25*$Yrotation}")",0"
			vs1=-1; hs1=-1;;
	   map) xsize=${Xsize[$1]}
			ysize=${Ysize[$1]}
			if [ $xsize -eq $ysize ]; then
				xl_pos="0,"$(awk "BEGIN {printf \"%.2f\", ${GPV[$ix,$iy,xlp]}+0.75}")"■center"
				yl_pos=$(awk "BEGIN {printf \"%.2f\", (${GPV[$ix,$iy,ylp]}-1)*$Digitscale}")",0■center■rotate■by■0"
                xt_pos="0,0.625"
                yt_pos="0.725,0"
            elif [ $xsize -gt $ysize ]; then
				xl_pos="0,"$(awk "BEGIN {printf \"%.2f\", -0.25+sqrt($ysize/$xsize.0)}")"■center"
 				yl_pos=$(awk "BEGIN {printf \"%.2f\", ${GPV[$ix,$iy,ylp]}*$Digitscale+$xsize/$ysize.0}")",0■center■rotate■by■0"
                xt_pos="0,0.625-($xsize-$ysize)/$xsize.0"
                yt_pos="0.375+sqrt(($xsize-$ysize)/$ysize.0),0"
            else
                xl_pos="0,"$(awk "BEGIN {printf \"%.2f\", 0.25+sqrt($ysize/$xsize.0)}")"■center"
				yl_pos=$(awk "BEGIN {printf \"%.2f\", (${GPV[$ix,$iy,ylp]}-sqrt($ysize/$xsize.0))*$Digitscale}")",0■center■rotate■by■0"
                xt_pos="0,0.325+sqrt(($ysize-$xsize)/$xsize.0)"
                yt_pos="1.325-0.5*$ysize/$xsize.0,0"
            fi
            echo "set xtics scale 0.625*sqrt($xsize/$ysize.0)
set ytics scale 0.625*sqrt($ysize/$xsize.0)" >> .me/gp
			vs1=-1; hs1=-1;;
	esac
	vs2=2.01; vs3=1.01
	unset_xt=0; unset_yt=0
	hs2=$(awk "BEGIN {printf \"%.2f\", ${GPV[hspace]}-3}")
	hs3=$(awk "BEGIN {printf \"%.2f\", 1.01}")
	if [[ $(echo $vspace $vs1 | awk '{if ($1 >= $2) print 1}') ]]; then
		echo "set xr[${GPV[$ix,$iy,xr]}]
set xlabel \"$xl\" offset $xl_pos $Fontset
set format x '%g'
set xtics offset $xt_pos nomirror out $xt $Fontset" >> .me/gp
	elif [ $(echo $vspace $vs2 | awk '{if ($1 >= $2) print 1}') ]; then
		echo "set xr[${GPV[$ix,$iy,xr]}]" >> .me/gp
		if [ $iy -eq $ey ]; then
			echo "set xlabel \"$xl\" offset $xl_pos $Fontset" >> .me/gp
		else
			echo "unset xlabel" >> .me/gp
		fi
		echo "set format x '%g'
set xtics offset $xt_pos nomirror out $xt $Fontset" >> .me/gp
	elif [ $(echo $vspace $vs3 | awk '{if ($1 >= $2) print 1}') ]; then
		echo "set xr[${GPV[$ix,0,xr]}]" >> .me/gp
		if [ $iy -eq $ey ]; then
			echo "set xlabel \"$xl\" offset $xl_pos $Fontset
set format x '%g'" >> .me/gp
		else
			echo "unset xlabel
set format x ''" >> .me/gp
		fi
		echo "set xtics offset $xt_pos nomirror out $xt $Fontset" >> .me/gp
	else
		echo "set xr[${GPV[$ix,0,xr]}]" >> .me/gp
		if [ $iy -eq $ey ]; then
			echo "set xlabel \"$xl\" offset $xl_pos $Fontset
set format x '%g'
set xtics offset $xt_pos nomirror out $xt $Fontset" >> .me/gp
		else
			echo "unset xlabel
set format x ''
unset xtics" >> .me/gp
			unset_xt=1
		fi
	fi
	[[ $(echo $hspace $hs3 | awk '{if ($1 < $2) print 1}') && $ix -lt $((${Layout[0]}-1)) && $unset_xt == 0 ]] && echo "set xtics add ('' ${GPV[$ix,$iy,xmax]})" >> .me/gp
	if [[ $(echo $hspace $hs1 | awk '{if ($1 >= $2) print 1}') ]]; then
		echo "set yr[${GPV[$ix,$iy,yr]}]
set ylabel \"$yl\" offset $yl_pos $Fontset
set format y '%g'
set ytics offset $yt_pos nomirror out $yt $Fontset" >> .me/gp
	elif [ $(echo $hspace $hs2 | awk '{if ($1 >= $2) print 1}') ]; then
		echo "set yr[${GPV[$ix,$iy,yr]}]" >> .me/gp
		if [ $ix -eq 0 ]; then
			echo "set ylabel \"$yl\" offset $yl_pos $Fontset" >> .me/gp
		else
			echo "unset ylabel" >> .me/gp
		fi
		echo "set format y '%g'
set ytics offset $yt_pos nomirror out $yt $Fontset" >> .me/gp
	elif [ $(echo $hspace $hs3 | awk '{if ($1 >= $2) print 1}') ]; then
		echo "set yr[${GPV[0,$iy,yr]}]" >> .me/gp
		if [ $ix -eq 0 ]; then
			echo "set ylabel \"$yl\" offset $yl_pos $Fontset
set format y '%g'" >> .me/gp
		else
			echo "unset ylabel
set format y ''" >> .me/gp
		fi
		echo "set ytics offset $yt_pos nomirror out $yt $Fontset" >> .me/gp
	else
		echo "set yr[${GPV[0,$iy,yr]}]" >> .me/gp
		if [ $ix -eq 0 ]; then
			echo "set ylabel \"$yl\" offset $yl_pos $Fontset
set format y '%g'
set ytics offset $yt_pos nomirror out $yt $Fontset" >> .me/gp
		else
			echo "unset ylabel
set format y ''
unset ytics" >> .me/gp
			unset_yt=1
		fi
	fi
	[[ $(echo $vspace $vs3 | awk '{if ($1 < $2) print 1}') && $iy -gt 0 && $unset_yt == 0 ]] && echo "set ytics add ('' ${GPV[$ix,$iy,ymax]})" >> .me/gp
	[[ $xl == "" ]] && sed -i 's|set xlabel "unset" .*$|unset xlabel|' .me/gp
	[[ $yl == "" ]] && sed -i 's|set ylabel "unset" .*$|unset ylabel|' .me/gp
}

function gnuplot_dgrid3d() {
	arrUsing=(${1//:/ })
    awk -v row=${arrUsing[0]} -v col=${arrUsing[1]} '
    {
        if (substr($row,1,1) ~ /[-.0-9]/) {
			record[$row][$col] = 1
			xvar = $row
        }
    }
    END {
		Lx = length(record[xvar])
		Ly = length(record)
		if (Lx > Ly) {
			r = log(Lx/Ly)/log(10)
		} else {
			r = log(Ly/Lx)/log(10)
		}
		if (r <= 1) {
			printf "%d,%d", Lx, Ly
		} else {
			print "off"
		}
    }' < "$2"
}

function gpscript_set_3d() {
	Zlabel[$1]=${Zlabel[$1]:-${Zlabel[$1-1]:-¶}}
	zl=${Zlabel[$1]}
    Ztics[$1]=${Ztics[$1]:-${Ztics[$1-1]:-auto}}
	zl_pos=$(awk "BEGIN {printf \"%.2f\",${GPV[$ix,$iy,zlp]}*$Digitscale}")",0,0■right■rotate■by■0"
	zt_pos="1.0,0,0"
    Using[$1,1]=${Using[$1,1]:-${Using[$1-1,1]:-1:2:c}}
	Dgrid=$(gnuplot_dgrid3d ${Using[$1,1]} ${Files[$1,0]})
	Pm3d[$1]=${Pm3d[$1]:-${Pm3d[$1-1]:-${Pm3d[0]}}}
	Palette[$1]=${Palette[$1]:-${Palette[$1-1]:-${Palette[0]}}}
	gpscript_palette ${Palette[$1]}
	echo "set zr[${GPV[$ix,$iy,zr]}]" >> .me/gp
	if [[ $zl == "" ]]; then
		echo "unset zlabel" >> .me/gp
	else
		echo "set zlabel \"$zl\" offset $zl_pos $Fontset" >> .me/gp
	fi
	echo "set format z '%g'
set ztics offset $zt_pos nomirror out ${Ztics[$1]} $Fontset
set ticslevel 0
set border 21
set grid x y z vertical lt -1 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymin]},${GPV[$ix,$iy,zmax]} to ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmax]} nohead lt -1 lw 0.5 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmax]} to ${GPV[$ix,$iy,xmax]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmax]} nohead lt -1 lw 0.5 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmax]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmin]} to ${GPV[$ix,$iy,xmax]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmax]} nohead lt -1 lw 0.5 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymin]},${GPV[$ix,$iy,zmin]} to ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmin]} nohead lt -1 lw 0.5 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmin]} to ${GPV[$ix,$iy,xmax]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmin]} nohead lt -1 lw 0.5 lc '#d4d3d3'
set arrow from ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmin]} to ${GPV[$ix,$iy,xmin]},${GPV[$ix,$iy,ymax]},${GPV[$ix,$iy,zmax]} nohead lt -1 lw 0.5 lc '#d4d3d3'
unset colorbox
unset hidden3d" >> .me/gp
	if [[ $Dgrid == "off" ]]; then
		echo "unset dgrid3d" >> .me/gp
	else
		echo "set dgrid3d $Dgrid
set hidden3d" >> .me/gp
	fi
    if [ ${Pm3d[$1]} == "on" ]; then
		echo "set pm3d depth lighting
set style fill transparent solid 0.4" >> .me/gp
	fi
	echo -e "set view ${View[$1]}
set palette $palette" >> .me/gp
}

function gpscript_set_map() {
    Using[$1,1]=${Using[$1,1]:-${Using[$1-1,1]:-1:2:c}}
    Dgrid=$(gnuplot_dgrid3d ${Using[$1,1]} ${Files[$1,0]})
	Palette[$1]=${Palette[$1]:-${Palette[$1-1]:-${Palette[0]}}}
	gpscript_palette ${Palette[$1]}
	Cbox[$1]=${Cbox[$1]:-${Cbox[$1-1]:-vertical}}
	cb=${Cbox[$1]}
	if [[ $cb == "vertical" ]]; then
		colorbox="vertical user origin graph 1+XC,0 size graph XC,1"
        ct_pos="-0.5,0"
	else
		colorbox="horizontal user origin graph 0,1+YC*0.5 size graph 1,XC"
        ct_pos="0,2.5"
	fi
	Ctics[$1]=${Ctics[$1]:-${Ctics[$1-1]:-auto}}
	echo "set view map
unset colorbox
unset grid
set dgrid3d $Dgrid
set pm3d map
set palette $palette
set colorbox $colorbox
set cbr[${GPV[$ix,$iy,cr]}]
set format cb '%g'
set cbtics offset $ct_pos scale 0.1 nomirror ${Ctics[$1]} $Fontset" >> .me/gp
}

function gpscript_plot() {
	awk -v Fig=$1 -v Graph=${Graph[$1]/d/} -v quote="'" 'BEGIN {N=1}
	{if ($1 == Fig) {Data[N] = $0; N++}}
	END {
		for (i=1; i<N; i++) {
			split(Data[i], c, " ")
			gsub("■", " ", c[6])
			gsub("§", "$", c[6])
            gsub("‖", "||", c[6])
            gsub(quote, "", c[12])
			if (c[2] == 1) {
				printf "%s \"%s\" u %s ", c[4], c[5], c[6]
			} else {
				printf "%*s \"%s\" u %s ", length(c[4]), " ", c[5], c[6]
			}
            if (c[12] ~ /#/) {c[12] = "\""c[12]"\""}
			if (c[7] == "¶" ) {printf ""}
			else if (c[7] == "l" ) {printf "w %s dt %s lw %s lc %s ", c[7], c[8],  c[9],  c[12]}
			else if (c[7] == "p" ) {printf "w %s pt %s ps %s lc %s ", c[7], c[10], c[11], c[12]}
			else if (c[7] == "lp") {printf "w %s dt %s lw %s pt %s ps %s lc %s ", c[7], c[8], c[9], c[10] ,c[11], c[12]}
			else {printf "w %s ",c[7]}
			if (c[13] != "\"\"") printf "t %s ", c[13]
			if (i < N-1) {
				printf ",\\\n"
			} else {
				printf "\n"
			}
		}
	}' .me/table >> .me/gp
}

function gnuplot_enhanced_characters() {
	case $Font in
		cmr10) sed -e 's|{s/\\245}|{w/\\061}|g
				s|{s/\\261}|{w/\\247}|g
				s|{s/\\265}|{w/\\057}|g
				s|{s/\\271}|{/Symbol \\271}|g
				s|{s/\\273}|{w/\\274}|g
				s|{s/\\320}|{/Symbol \\320}|g' .me/gp > .me/tmp
            awk 'BEGIN {
				for (i=65;i<91;i++) oct[sprintf("%c",i)] = sprintf("%o",i)
				for (i=97;i<123;i++) oct[sprintf("%c",i)] = sprintf("%o",i+77)
				oct["C"]=130; oct["D"]=242; oct["F"]=251; oct["G"]=241; oct["J"]="043";oct["L"]=244;
				oct["P"]=246; oct["Q"]=243; oct["R"]=120; oct["S"]=247; oct["U"]=250;  oct["V"]="046";
				oct["W"]=255; oct["X"]=245; oct["Y"]=252;
				oct["c"]=302; oct["f"]=301; oct["g"]=260; oct["h"]=264; oct["i"]=266;  oct["j"]="047";
				oct["k"]=267; oct["l"]=270; oct["m"]=271; oct["n"]=272; oct["o"]="045";oct["p"]=274;
				oct["q"]=265; oct["r"]=275; oct["s"]=276; oct["t"]=277; oct["u"]=300;  oct["v"]="044";
				oct["x"]=273; oct["y"]=303; oct["z"]=263
				#for (key in oct) print key, oct[key]
			}
			{
				if ($0 ~ /{s\//) {
					gsub(/{s\/\/|{s\//,"& ",$0)
					for (i=3; i<=NF; i++) {
						if ($i ~ /^[a-zA-Z]+}/) {
							for (j=1; j<length($i); j++) {
								char = substr($i,k,1)
								if (char != "}") {
									gsub(char,"§"oct[char],$i)
									break
								}   
							}
						}
					}
				}
				print $0
			}' .me/tmp | sed -e 's| / §|/\\|g;s| §|\\|g' > .me/gp
			sed -e 's|{/\([^/]\)|{/cmr10 \1|g
				s|{//|{/cmti10 |g
				s|{b/\([^/]\)|{/cmb10 \1|g
				s|{b//|{/cmbxti10 |g
				s|{s/\([^/]\)|{/cmr10 \1|g
				s|{s//|{/cmmi10 |g
				s|{w/\([^/]\)|{/cmsy10 \1|g
				s|\||{/cmsy10 \\152}|g
				s|\|\||{/cmsy10 \\153}|g
				/label/s|'"'"'|^{/cmsy10 \\060}|g
				/ t /s|'"'"'|^{/cmsy10 \\060}|g' .me/gp > .me/tmp;;
		Arial) sed -e 's|{s/\\077}|{/cmsy10 \\077}|g
			s|{s/\\153}|{/cmsy10 \\153}|g
			s|{/\([^/]\)|{/Arial \1|g
			s|{//|{/Arial-Italic |g
			s|{b/\([^/]\)|{/Arial-Bold \1|g
			s|{b//|{/Arial-Bold-Italic |g
			s|{s/\([^/]\)|{/Symbol \1|g
			s|{s//|{/Symbol-Oblique |g
			s|{w/\([^/]\)|{/ZapfDingbats \1|g' .me/gp > .me/tmp;;
		Times) sed -e 's|{s/\\077}|{/cmsy10 \\077}|g
			s|{s/\\153}|{/cmsy10 \\153}|g
			s|{/\([^/]\)|{/Times \1|g
			s|{//|{/Times-Italic |g
			s|{b/\([^/]\)|{/Times-Bold \1|g
			s|{b//|{/Times-Bold-Italic |g
			s|{s/\([^/]\)|{/Symbol \1|g
			s|{s//|{/Symbol-Oblique |g
			s|{w/\([^/]\)|{/ZapfDingbats \1|g' .me/gp > .me/tmp;;
	esac
    sed -e 's|¶||g
        s|‖|\|\||g
        s|§|$|g
		s|■| |g
    	s|\^\.|\&{^.}|g
		s|\.\.|\&{.}|g
		s|\,\,| |g
		s|\_\_|\&{a}|g' .me/tmp
}

function gpscript_unset_3daxis() {
    echo "# --> Hide 3D Axis <--
unset xlabel
unset xtics
unset ylabel
unset ytics
unset zlabel
unset ztics
unset border
unset grid
unset arrow" >> .me/gp
}

function xgnuplot() {
    [[ ${FS:- } == " " ]] && separator=whitespace || separator="'$FS'"
    gnuplot_show_variables
	gnuplot .me/gp 2> .me/gpval
	gnuplot_gpval
    eval declare -A GPV=("$GPV_str")
    #declare -p GPV
	gpscript_head
	for ((i=0; i<Total_figures; i++)); do
        ix=${Xsite[i]}
        iy=${Ysite[i]}
        Graph[$i]=${Graph[i]:-${Graph[i-1]:-2d}}
        View[$i]=${View[i]:-${View[i-1]:-60,52.5}}
		Vx=${View[$1]%,*}; Vz=${View[$1]#*,}
 		echo -e "\n# --- Figure $((i+1)) ---" >> .me/gp
        gpscript_set_origin $i
        gpscript_set_axis $i
        case ${Graph[i]} in
            3d) gpscript_set_3d $i
                Axis3d[$i]=${Axis3d[i]:-${Axis3d[i-1]:-on}}
                [[ ${Axis3d[i]} == "off" ]] && gpscript_unset_3daxis;;
		   map) gpscript_set_map $i;;
        esac
        gpscript_plot $i
	done
	gnuplot_enhanced_characters > $Output.gp
	gnuplot $Output.gp
}

function ylprt() {
	if [[ $1 == "" ]]; then
		df=$(grep "\" u" .me/gp | sed -e 's/.*\"\(.*\)\" u.*/\1/' | uniq)
		zip -r $Output.zip .me $df
	else
		df=$(grep "\" u" ${1##.*}.gp | sed -e 's/.*\"\(.*\)\" u.*/\1/' | uniq)
		zip -r $Output.zip .me ${1##.*}.gp ${1##.*}.pdf $df
	fi
}

#<-- Drop 2nd-level parameters -->
for ((n=0; n<${#drop[*]}; n++)); do
	unset Arg[${drop[$n]}]
done

Arg=(${Arg[*]})
drop=()

#<-- Parameters : gnuplot script -->
for ((n=0; n<${#Arg[*]}; n++)); do
	if [ -e ${Arg[$n]} ]; then
		case ${Arg[$n]#*.} in
			gp)	output=$(awk '/set output/{gsub("\"","",$3);print $3;exit}' ${Arg[$n]})
				save=${Arg[$n]%.*}.pdf
                [[ $output != $save ]] && sed -i "/output/s/$output/$save/" ${Arg[$n]} 
				echo ${Arg[$n]}" --> "$save
				gnuplot ${Arg[$n]}
				exit;;
		   zip) unzip -o ${Arg[$n]}
				exit;;
		esac
	fi
	case ${Arg[$n]} in
		-gp)	xgnuplot;next;continue;;
		-eps)	pdftops ${Output:-fig}.pdf .me/ps;ps2eps -f .me/ps;mv .me/ps.eps ${Output:-fig}.eps;next;continue;;
		-eylprt)ylprt ${Arg[$n+1]};next;continue;;
		-new)	rm .me/.var .me/table .me/gp 2> /dev/null;exit;;
		-view)	Viewer="${Arg[$n+1]}";next 2;continue;;
	esac
done

#-========-========-======-=========-=======-===-===---========-========-========---

function awk_user_defined_functions() {
	echo "function pi() {return 3.14159265359}
function abs(value) {return (value<0?-value:value)}
function tan(value) {return sin(value)/cos(value)}
function asin(value) {
	if (value==1) {
		return 1.57079632675
	} else {
		y=x=value
		c=1
		for (n=3; n<=15; n+=2) {
			c=c*(n-2)/(n-1)
			x=x*x**2
			y=y+c*x/n
		}
		return y
	}
}
function acos(value) {return 1.57079632675-asin(value)}
function atan(value) {
	if (value==1) {
		return 0.785398163375
	} else {
		y=x=value
		c=1
		for (n=3; n<=15; n+=2) {
			c=c*(-1)
			x=x*x**2
			y=y+c*x/n
		}
		return y
	}
}
function sinh(value) {return (exp(value)-exp(-value))/2}
function cosh(value) {return (exp(value)+exp(-value))/2}
function tanh(value) {return (exp(value)-exp(-value))/(exp(value)+exp(-value))}"
}

function print_logfile() {
	head -5 $1
	echo -e "\t⋮"
	tail -5 $1
}

function data_transpose() {
	awk '{
		for (i=1; i<=NF; i++) {
			row[i] = row[i] " " $i
			L = $i >= 0 ? length($i) : length($i) - 1
			Lmax[NR] = Lmax[NR] > L ? Lmax[NR] : L
		}
	}
    END {
		for (i=1; i<=NF; i++) {
			split(row[i],r," ")
			for (k=1; k<=length(Lmax); k++) {
				if (r[k] >= 0) {
					printf " %-*s ",Lmax[k],r[k]
				} else {
					printf "-%-*s ",Lmax[k],-r[k]
				}
			}
			printf "\n"
		}
	}' < $Files > .me/tmp
	print_logfile .me/tmp
	mv .me/tmp ${datafile%.*}.tra
}

function set_operand() {
	variable=""
	for A in $(echo "$1" | sed -e 's|\$\([0-9]*\)|f\1[NR]=$\1; |g; s|c\([0-9]*\)|c\1[NR]=$\1; |g'); do
		variable="$variable$(echo $A | sed -e 's|^.*\([cf]\)|\1|;s|^[^cf].*||')"
	done
	operand=$(echo "$1" | sed -e 's|\$\([0-9]*\)|f\1[i]|g; s|c\([0-9]*\)|c\1[k]|g')
	incycle=$(echo "$operand" | awk '/c[0-9]*\[k\]/{print "1"}')
}

function data_calculation() {
	echo "# $1" > .me/tmp
	set_operand "$1"
	awk -v incycle=$incycle "$(awk_user_defined_functions)
    {
		$variable
		sub(/\r/,\"\",\$0)
		row[NR] = \$0
		for (i=1; i<=NF; i++) {
			L = \$i >= 0 ? length(\$i) : length(\$i) - 1
			Lmax[i] = Lmax[i] > L ? Lmax[i] : L
		}
	}
    END {
		if (incycle == 1) {N2 = NR} else {N2 = 1}
		for (i=1; i<=NR; i++) {
			A[i] = 0
			for (k=1; k<=N2; k++) {
				A[i] += $operand
			}
			row[i] = row[i]\"  \"A[i]
			L = A[i] >= 0 ? length(A[i]) : length(A[i]) - 1
			Lmax[NF+1] = Lmax[NF+1] > L ? Lmax[NF+1] : L
		}
		for (i=1; i<=NR; i++) {
			split(row[i],r,\" \")
			for (k=1; k<=length(Lmax); k++) {
				if (r[k] >= 0) {
					printf \" %-*s  \",Lmax[k],r[k]
				} else {
					printf \"-%-*s  \",Lmax[k],-r[k]
				}
			}
			printf \"\\n\"
		}
	}" < $datafile >> .me/tmp
	echo -e "  \033[1m$datafile -->> ${datafile%.*}.log\033[0m"
	print_logfile .me/tmp
	mv .me/tmp ${datafile%.*}.cal
}

function data_derivative() {
	echo "# $1" > .me/tmp
	Y=${1%\/*}
	X=${1#*\/}
	awk -v X=${X#d} -v Y=${Y#d} '
	BEGIN {
        x1=x2=0;y1=y2=0
    }
    {
		y1=y2; y2=$Y; dy=y2-y1
		x1=x2; x2=$X; dx=x2-x1
		if (dx==0) {A[NR]=0} else {A[NR]=dy/dx}
		for (i=1; i<=NF; i++) {
			L = $i >= 0 ? length($i) : length($i) - 1
			Lmax[i] = Lmax[i] > L ? Lmax[i] : L
		}
		sub(/\r/,\"\",\$0)
		row[NR] = \$0
	}
    END {
		for (i=1;i<=NR;i++) {
			row[i] = row[i] " " A[i]
			L = A[i] >= 0 ? length(A[i]) : length(A[i]) - 1
			Lmax[NF+1] = Lmax[NF+1] > L ? Lmax[NF+1] : L
		}
		for (i=1; i<=NR; i++) {
			split(row[i],r," ")
			for (k=1; k<=length(Lmax); k++) {
				if (r[k] >= 0) {
					printf " %-*s ",Lmax[k],r[k]
				} else {
					printf "-%-*s ",Lmax[k],-r[k]
				}
			}
			printf "\n"
		}
	}' < $datafile >> .me/tmp
	echo -e "  \033[1m$datafile -->> ${datafile%.*}.log\033[0m"
	print_logfile .me/tmp
	mv .me/tmp ${datafile%.*}.dif
}

function data_integral() {
	set_operand "$1"
	X=$(echo "$1" | sed 's|^.*\(d[0-9]*\).*|\1|')
	operand=${operand/$X/}
	operand=${operand#\*}
	operand=${operand%\*}
	awk -v incycle=$incycle "$(awk_user_defined_functions)
    BEGIN {
        x1=x2=0
    }
    {
		x1=x2; x2=\$$X; dx[NR]=(x2-x1)
		$variable
	}
    END {
		if (incycle == 1) {N2 = NR} else {N2 = 1}
		for (i=1; i<=NR; i++) {
			I1 = I2 = 0
			for (k=1; k<=N2; k++) {
				I1 += dx[i]   * $operand
				I2 += dx[i+1] * $operand
			}
			I += (I1+I2)*0.5
		}
		printf \"∫ $1=%g\\n\",I
	}" < $datafile
}

function data_fourier_transform() {
    if [[ $datafile == "" ]]; then
        echo "No such a file."
        exit
    fi
	[ ! -f ${datafile%.*}.fft ] && touch ${datafile%.*}.fft
    X=$(awk -F: '{print $1}' <<< $1)
    Y=$(awk -F: '{print $2}' <<< $1)
    Z=$(awk -F: '{print $3}' <<< $1)
    if [[ $Z == "" ]]; then
        echo "   \"${datafile:-_____.dat}\" u ${X:-x}:${Y:-y}"
		Z=$Y
		Y=$X
		Grid=$(gnuplot_dgrid3d $X $datafile)
    else
        echo "   \"${datafile:-_____.dat}\" u ${X:-x}:${Y:-y}:${Z:-z}"
		Grid=$(gnuplot_dgrid3d $X:$Y $datafile)
    fi
    echo "   K-center offset =（${BZoffset[0]} , ${BZoffset[1]}）"
    if [[ $X == "" || $Y == "" ]]; then
        echo "Empty file."
        exit
    fi
    echo "<<---  ${datafile%.*}.fft  --->>"
	awk -v X=$X -v Y=$Y -v Z=$Z -v Kxoffset=${BZoffset[0]} -v Kyoffset=${BZoffset[1]} -v Ny=${Grid%,*} -v Nx=${Grid#*,} '
    BEGIN {
       pi=3.14159265359
    }
    {
		Rx[NR]=$X
		Ry[NR]=$Y
		where = match($Z,/[0-9][+-][-.0-9e]*i/)
		if (where==0) {
			FR[NR]=$Z
			FI[NR]=0.0
		} else {
			FR[NR]=substr($Z,1,where)
			FI[NR]=substr($Z,where+1,length($Z)-where-1)
		}        
    }
    END {
		if (X == Y) {Ny=1}
		m = 1
		for (ix=0; ix<Nx; ix++) {
			for (iy=0; iy<Ny; iy++) {
				Kx = 2*pi*ix/Nx - pi - Kxoffset
				Ky = 2*pi*iy/Ny - pi - Kyoffset
				GR[m] = GI[m] = 0
				for (i=1; i<=NR; i++) {
					Q = Kx*Rx[i] + Ky*Ry[i] - pi
					GR[m] +=  FR[i]*cos(Q) + FI[i]*sin(Q)
					GI[m] += -FR[i]*sin(Q) + FI[i]*cos(Q)
				}
				if (GI[m] >= 0) {A[m] += " " GR[m] "+" GI[m] "i"} else {A[m] += " " GR[m] GI[m] "i"}
				if (Ny == 1) {
					row[m] = row[m] " " Kx-pi " " A[m]
					L = Kx-pi >= 0 ? length(Kx-pi) : length(Kx-pi)-1
					Lmax[1] = Lmax[1] > L ? Lmax[1] : L
					L = GR[m] >= 0 ? length(A[m]) : length(A[m]) - 1
					Lmax[2] = Lmax[2] > L ? Lmax[2] : L
				} else {
					row[m] = row[m] " " Kx-pi " " Ky-pi " " A[m]
					L = Kx-pi >= 0 ? length(Kx-pi) : length(Kx-pi)-1
					Lmax[1] = Lmax[1] > L ? Lmax[1] : L
					L = Ky-pi >= 0 ? length(Ky-pi) : length(Ky-pi)-1
					Lmax[2] = Lmax[2] > L ? Lmax[2] : L
					L = GR[m] >= 0 ? length(A[m]) : length(A[m]) - 1
					Lmax[3] = Lmax[3] > L ? Lmax[3] : L
				}
				m ++
			}
		}
		for (i=1; i<=NR; i++) {
			split(row[i],r," ")
			for (k=1; k<=length(Lmax); k++) {
				if (r[k] >= 0) {
					printf " %-*s ",Lmax[k],r[k]
				} else {
					printf "-%-*s ",Lmax[k],-r[k]
				}
			}
			printf "\n"
		}
	}' < $datafile > .me/tmp
	print_logfile .me/tmp
	mv .me/tmp ${datafile%.*}.fft
}

#<-- Drop 3rd-level parameters -->
for ((n=0; n<${#drop[*]}; n++)); do
	unset Arg[${drop[$n]}]
done

Arg=(${Arg[*]})
drop=()

#<-- Parameters : arithmetics -->
for ((n=0; n<${#Arg[*]}; n++)); do
	case ${Arg[$n]} in
		-tra) data_transpose;next;exit;;
		-cal) data_calculation ${Arg[$n+1]};next 2;exit;;
		-der) data_derivative ${Arg[$n+1]};next 2;exit;;
		-int) data_integral ${Arg[$n+1]};next 2;exit;;
		-fft) data_fourier_transform ${Arg[$n+1]};next 2;exit;;
	esac
done

#-========-========-======-=========-=======-===-===---========-========-========---

function concatEPS() {
	if [ ${#epsfile[*]} -lt 2 ]; then
		echo "The number of EPS files must be larger than 1."
		exit
	fi
	space=${2:-2}
	for ((n=0; n<${#epsfile[*]}; n++)); do
		bbox=($(grep 'Box:' ${epsfile[$n]} | tr '\r' '\n' | cut -d ' ' -f 2-5))
		Xsize[$n]=$((bbox[2]-bbox[0]))
		Ysize[$n]=$((bbox[3]-bbox[1]))
		Xtotal=$((Xtotal+Xsize[n]))
		Ytotal=$((Ytotal+Ysize[n]))
		if [ $n -gt 0 ]; then
			if [[ $1 == "htile" ]]; then
				Xtotal=$((Xtotal+space))
			else
				Ytotal=$((Ytotal+space))
			fi
		fi
	done
	Xtop=$((-Xtotal/2))
	Ytop=$((Ytotal/2))
	Xbefore=0
	Ybefore=0
	echo "%!PS-Adobe-2.0 EPSF-2.0" > .me/ps
	for ((n=0; n<${#epsfile[*]}; n++)); do
		echo "gsave" >> .me/ps
		if [[ $1 == "htile" ]]; then
			Xtop=$((Xtop+Xbefore+Xsize[n]/2))
			echo "$Xtop 0 translate" >> .me/ps
			Xbefore=$((Xsize[n]/2+space))
		else
			Ytop=$((Ytop-Ybefore-Ysize[n]/2))
			echo "0 $Ytop translate" >> .me/ps
			Ybefore=$((Ysize[n]/2+space))
		fi
		sed -e "s/showpage//g" ${epsfile[$n]} >> .me/ps
		echo "grestore" >> .me/ps
	done
	echo "showpage" >> .me/ps
    ps2pdf .me/ps ${Output:-fig}.pdf
}

function update() {
	echo "Current version"
	sed -n -e '5p' $HOME/bin/me
	wget -q http://web.phy.ntnu.edu.tw/~hongyi/download/me.sh -O $HOME/bin/me.sh
	err=$?
	if [ $err -ne 0 ]; then
		echo "Update failed! Please try again."
		rm -f $HOME/bin/me.sh
		exit
	else
		echo "Updated version"
		sed -n -e '5p' $HOME/bin/me.sh
		chmod 755 $HOME/bin/me.sh
		mv $HOME/bin/me.sh $HOME/bin/me
	fi
}

function help() {
	L=$(echo -e "\033[32m【\033[0m")
	R=$(echo -e "\033[32m】\033[0m")
	S=$(echo -e "\033[33m∕\033[0m")
	C=$(echo -e "\033[91m")
	N=$(echo -e "\033[0m")
	echo "Page:     me -page portrait|landscape|square
Font:     me -font cm|arial|times<<,13>>
Merge:    me -m0|-ma|-mc|-mf
Layout:   me -N<<number>>|-Z<<number>>
Space:    me -space 10,10
────<-- available with choosing figure -a -->────
Figure:   me -a|-b|-c|···
Datafile: me xxx.txt yyy.txt
X-column: me -u '1:c'
Y-column: me [2:8]
Size:     me -size 200,134
Offset:   me -offset 10,20
Index:    me -I '(A)'|on|off
Caption:  me -ic '{s/D}{//E}..=..0.5'
Position: me -ip <<position>>
X-label:  me -xl '{//E}'
X-range:  me -xr -pi:pi
X-tics:   me -xt 1
Y-label:  me -yl '{s//r}({//E})'
Y-range:  me -yr 0.1:0.4
Y-tics:   me -yt 0.1
────<-- available with choosing figure -a -->────
Key box:  me -kb -0.5<<|on|off>>
Position: me -kp <<position>>
────<-- available with choosing line -a1 -->─────
Line:     me -a1|-a2|-a3|···
Key:      me -K <<text>>|vertical|horizontal
Label:    me -L <<text>>
Position: me -lp <<position<<,fontsize>>>>" > .me/.left
	awk '{
		L = L > length($0) ? L : length($0)
		c[NR] = $0
	} END {
		for (i=1; i<=NR; i++) {
			dl = L - length(c[i])
			printf "%-s%*s│\n",c[i],dl+1," "
		}
	}' .me/.left > .me/.left_new
	mv .me/.left_new .me/.left
	echo "Using:       me -u '1:(\$2>0?\$2:1/0)'
With:        me -w l|p
Dash type:   me -dt 1
Line width:  me -lw 2
Point type:  me -pt 7
Point size:  me -ps 0.5
Line color:  me -lc 6|palette
────<-- available with choosing line -a1 -->─────
Swap:        me -swap <<a1>><<a2>>
Move:        me -move <<a1>><<a2>>
────<-- available with choosing figure -a -->────
Graph:       me -graph 2d|3d|map
Z-label:     me -zl '{s/D}{//E}'
Z-range:     me -zr 0.1:0.4
Z-tics:      me -zt 0.1
View:        me -view rot-x,rot-z
Pm3d:        me -pm3d on|off<<|colormap>>
Axis3d:      me -axis3d on|off
────<-- only used as graph=map -->───────────────
Color-box:   me -cb vertical|horizontal
Color-range: me -cr 0.1:0.4
Color-tics:  me -ct 1
─────────────────────────────────────────────────
Tile:        me -vtile|-htile <<space>><<files>>
GnuPlot:     me -gp
EPS file:    me -eps
Export:      me -export <<filename>>
Output:      me -O <<filename>>
             me -new|-update" > .me/.right
	sed -i -e "/^[^<]/{s!<<!$L!g;s!>>!$R!g;s!|!$S!g};s!<--!$C<--!g;s!-->!-->$N!g" .me/.left
	sed -i -e "/^[^<]/{s!<<!$L!g;s!>>!$R!g;s!|!$S!g};s!<--!$C<--!g;s!-->!-->$N!g" .me/.right
	paste -d '' .me/.left .me/.right
	rm -f .me/.left .me/.right
    echo -en "\033[0m\033[100mPress any key to continue\r\033[0m"
    read -d '' -sn1
    clear
	echo "<-- Fonts -->
    {/ }    (Roman)
    {// }   (Italic)
    {b/ }   (Bold)
    {b// }  (Bold-Italic)
    {s/ }   (Symbol)
    {s// }  (Symbol-Oblique)
    {w/ }   (Artistic)
<-- Greek Letters -->
    A:A    B:B    C:Χ    D:Δ    E:Ε    F:Φ
    G:Γ    H:Η    I:Ι    K:Κ    L:Λ    M:M
    N:N    O:O    P:Π    Q:Θ    R:Ρ    S:Σ
    T:Τ    U:Υ    W:Ω    X:Ξ    Y:Ψ    Z:Z
    a:α    b:β    c:χ    d:δ    e:ε    f:φ
    g:γ    h:η    i:ι    k:κ    l:λ    m:μ
    n:ν    o:ο    p:π    q:θ    r:ρ    s:σ
    t:τ    u:υ    w:ω    x:ξ    y:ψ    z:ζ
<-- Math Symbols -->
    \245:∞    \261:±    \265:∝    \271:≠
    \273:≈    \320:∠    \077:⊥    \153:∥
─────────────────────────────────────────────────
<-- Blank -->
    {}    (delete)
    ^.    (quarter-space: \"^.\")
    ..    (half-space: \".\")
    ,,    (three-quarters-space whitespace: \" \")
    __    (full-space: \"A\")" > .me/.left
	awk '{
		L = L > length($0) ? L : length($0)
		c[NR] = $0
	} END {
		for (i=1; i<=NR; i++) {
			dl = L - length(c[i])
			printf "%-s%*s│\n", c[i], dl+1, " "
		}
	}' .me/.left > .me/.left_new
	mv .me/.left_new .me/.left
	echo -e "<-- Position -->
 sh  hl    h    hr        (s:slash) (h:header)
    ┌──────┬──────┐
    │tl    t    tr│ to    (o:outside)
    │      │      │
    ├l ─── c ─── r┤ o
    │      │      │
    │bl    b    br│ bo
    └──────┴──────┘
	0.5,0.5,center<<,fontsize>>
────────────────────────────────────────────────
<-- Colormaps of Pm3d -->
    heat     \033[34m▬▬\033[36m▬▬\033[96m▬▬\033[97m▬▬\033[91m▬▬\033[31m▬▬\033[0m
    jet      \033[34m▬▬\033[36m▬▬\033[92m▬▬\033[93m▬▬\033[91m▬▬\033[31m▬▬\033[0m
    parula   \033[34m▬▬\033[94m▬▬\033[36m▬▬\033[92m▬▬\033[93m▬▬\033[97m▬▬\033[0m  (default)
    viridis  \033[35m▬▬\033[34m▬▬\033[94m▬▬\033[36m▬▬\033[92m▬▬\033[93m▬▬\033[0m
    green
    grey
────────────────────────────────────────────────
<-- Numerics -->
Transpose:   me -tra
Calculation: me -cal '\$1*sin(30)'
Derivative:  me -der d3/d1
Integral:    me -int 'exp(\$2-c1)*d1'
Fourier:     me -fft 1:2<<:3>>
BZ Offset:   me -bz pi,pi" > .me/.right
	sed -i -e "/^[^<]/{s!<<!$L!g;s!>>!$R!g;s!|!$S!g};s!<--!$C<--!g;s!-->!-->$N!g" .me/.left
	sed -i -e "/^[^<]/{s!<<!$L!g;s!>>!$R!g;s!|!$S!g};s!<--!$C<--!g;s!-->!-->$N!g" .me/.right
	paste -d '' .me/.left .me/.right
	rm -f .me/.left .me/.right
}

for ((n=0; n<${#drop[*]}; n++)); do
	unset Arg[${drop[$n]}]
done

Arg=(${Arg[*]})
drop=()

for ((n=0; n<${#Arg[*]}; n++)); do
	if [[ -e ${Arg[$n]} && ${Arg[$n]#*.} == "eps" ]]; then
        epsfile+=(${Arg[$n]});next;continue
	fi
done

for ((n=0; n<${#drop[*]}; n++)); do
	unset Arg[${drop[$n]}]
done

Arg=(${Arg[*]})

for ((n=0; n<${#Arg[*]}; n++)); do
	case ${Arg[$n]} in
		-vtile|-htile) concatEPS ${Arg[$n]#-} ${Arg[$n+1]};continue;;
		-help) clear;help;continue;;
		-update) update;continue;;
		*) echo "Unknown argument [$n/"${#Arg[*]}"]: "${Arg[$n]};exit;;
	esac
done
