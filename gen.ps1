$outDir = "c:\Users\rashi\StudioProjects\choco_blast_adventure\assets\audio"
if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir }

function Generate-Wav($filename, $freqFunc, $dur, $volFunc, $saw) {
    $fs = [System.IO.File]::Create("$outDir\$filename")
    $bw = New-Object System.IO.BinaryWriter($fs)
    $sampleRate = 44100
    $numSamples = [int]($sampleRate * $dur)
    
    $bw.Write([char[]]"RIFF")
    $bw.Write([int](36 + $numSamples * 2))
    $bw.Write([char[]]"WAVE")
    $bw.Write([char[]]"fmt ")
    $bw.Write([int]16)
    $bw.Write([int16]1)
    $bw.Write([int16]1)
    $bw.Write([int]$sampleRate)
    $bw.Write([int]($sampleRate * 2))
    $bw.Write([int16]2)
    $bw.Write([int16]16)
    $bw.Write([char[]]"data")
    $bw.Write([int]($numSamples * 2))
    
    $rand = New-Object Random
    for($i=0; $i -lt $numSamples; $i++) {
        $t = $i / $sampleRate
        
        $vol = 1.0
        if ($volFunc -eq "fadeout") { $vol = 1 - ($t / $dur) }
        elseif ($volFunc -eq "fadeout2") { $vol = [math]::Pow(1 - ($t / $dur), 2) }
        elseif ($volFunc -eq "bg") { $vol = 0.2 }
        
        $val = 0.0
        if ($freqFunc -eq "noise") {
            $val = ($rand.NextDouble() * 2 - 1) * $vol
        } elseif ($saw) {
            $f = 150.0
            $val = 2.0 * ($t * $f - [math]::Floor(0.5 + $t * $f)) * $vol
        } else {
            $f = 440.0
            if ($freqFunc -eq "button") { $f = 880.0 }
            elseif ($freqFunc -eq "match") { $f = 440.0 + 880.0 * ($t/$dur) }
            elseif ($freqFunc -eq "swap") { $f = 300.0 - 100.0 * ($t/$dur) }
            elseif ($freqFunc -eq "bg") { 
                $notes = @(261.63, 329.63, 392.00, 523.25)
                $noteIdx = [int]($t * 4) % 4
                $f = $notes[$noteIdx]
                $val = [math]::Sin(2 * [math]::PI * $f * ($t % 0.25)) * $vol
            }
            if ($freqFunc -ne "bg") {
                $val = [math]::Sin(2 * [math]::PI * $f * $t) * $vol
            }
        }
        
        $ival = [int]($val * 32767)
        if ($ival -gt 32767) { $ival = 32767 }
        if ($ival -lt -32768) { $ival = -32768 }
        $bw.Write([int16]$ival)
    }
    $bw.Close()
    $fs.Close()
}

Generate-Wav "button.wav" "button" 0.1 "fadeout" $false
Generate-Wav "match.wav" "match" 0.3 "fadeout" $false
Generate-Wav "swap.wav" "swap" 0.15 "fadeout" $false
Generate-Wav "invalid.wav" "invalid" 0.3 "fadeout" $true
Generate-Wav "special.wav" "noise" 0.6 "fadeout2" $false
Generate-Wav "bg_music.wav" "bg" 4.0 "bg" $false
