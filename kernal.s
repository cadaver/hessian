        ;Kernal zeropage variables

status          = $90
messages        = $9d
fa              = $ba

        ;BASIC vectors

ierror          = $0300
imain           = $0302

        ;Kernal routines

ScnKey          = $ff9f
CIOut           = $ffa8
Listen          = $ffb1
Second          = $ff93
UnLsn           = $ffae
Talk            = $ffb4
Tksa            = $ff96
UnTlk           = $ffab
ACPtr           = $ffa5
ChkIn           = $ffc6
ChkOut          = $ffc9
ChrIn           = $ffcf
ChrOut          = $ffd2
Close           = $ffc3
ClAll           = $ffe7
Open            = $ffc0
SetMsg          = $ff90
SetNam          = $ffbd
SetLFS          = $ffba
ClrChn          = $ffcc
GetIn           = $ffe4
Load            = $ffd5
Save            = $ffd8
