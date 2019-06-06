#!/bin/bash

KEY='\0'
DT=0.1
block='█'

sizeX=$(tput cols)
sizeY=$(tput lines)

#P-Player C-CPU
PY=$(( $sizeY / 2))
CY=$PY

PX=1
CX=$sizeX

minY=3
maxY=$(($sizeY - 2))

BX=$(($sizeX / 2))
BY=$(($sizeY / 2))

dx=-1
dy=-1

updateSpeed()
{
    DT=$(echo "$DT * 0.99" |bc)
}

moveBall()
{
    if (($BY == 1)); then
        dy=-$dy
    elif (($BY == $sizeY)); then
        dy=-$dy
    fi
    if (($BX <= 2)); then
        ((DIFF=$PY-$BY))
        if ((${DIFF#-} < 3)); then
            dx=${dx#-}
            updateSpeed
        fi
    elif  (($BX >= ($sizeX-1) )); then
        ((DIFF=$CY-$BY))
        if ((${DIFF#-} < 3)); then
            dx=-$dx
            updateSpeed
        fi
    fi
    
    if (($BX == 1)) || (($BX == $sizeX)); then
        BX=$(($sizeX / 2))
        BY=$(($sizeY / 2))
    fi

    

    BY=$(($BY+$dy))
    BX=$(($BX+$dx))
}

signum()
{
    echo $(( ($1 > 0) - ($1 < 0) ))
}

#x y text
printAt() { echo -en "\e[$2;${1}f$3"; }

playerPaddleUp()
{
    if (($PY > $minY));
    then
        PY=$(($PY-1))
    fi
}

playerPaddleDown()
{
    if (($PY < $maxY));
    then
        PY=$(($PY+1))
    fi
}

cpuPaddleUp()
{
    if (($CY > $minY));
    then
        CY=$(($CY-1))
    fi
}

cpuPaddleDown()
{
    if (($CY < $maxY));
    then
        CY=$(($CY+1))
    fi
}

tick() 
{
    case "$KEY" in
        q) exit ;;
        w) playerPaddleUp; KEY='\0' ;;
        s) playerPaddleDown; KEY='\0' ;;
        *) : ;;
    esac

    if (( RANDOM % 2 )); then
        if (($BY < $CY)); then
            cpuPaddleUp
        elif (($BY > $CY)); then
            cpuPaddleDown
        fi
    fi
    
    moveBall

    clear
    for i in {-2..2}
    do
        printAt $PX $(($PY + $i)) $block
        printAt $CX $(($CY + $i)) $block
    done
    printAt $BX $BY $block

    ( sleep $DT; kill -ALRM $$ )&
}

quit() {
    printf "\e[?12l\e[?25h"  # cursor on
    tput rmcup
}

trap quit ERR EXIT

tput smcup
printf "\e[?25l"  # cursor off
printf "\e]0;PONG\007"

trap tick ALRM
tick

while :; do
    read -rsn1 KEY
done

