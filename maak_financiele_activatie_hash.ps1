$ErrorActionPreference = "Stop"

function New-SecureRandomCode {
    param(
        [int]$GroupCount = 8,
        [int]$GroupLength = 4
    )

    $alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    $alphabetLength = $alphabet.Length
    $maxAcceptedByte = [Math]::Floor(256 / $alphabetLength) * $alphabetLength
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    try {
        $groups = @()

        for ($groupIndex = 0; $groupIndex -lt $GroupCount; $groupIndex++) {
            $builder = New-Object System.Text.StringBuilder

            while ($builder.Length -lt $GroupLength) {
                $buffer = New-Object byte[] 1
                $rng.GetBytes($buffer)

                if ($buffer[0] -ge $maxAcceptedByte) {
                    continue
                }

                $characterIndex = $buffer[0] % $alphabetLength
                [void]$builder.Append($alphabet[$characterIndex])
                [Array]::Clear($buffer, 0, $buffer.Length)
            }

            $groups += $builder.ToString()
        }

        return ($groups -join "-")
    }
    finally {
        $rng.Dispose()
    }
}

function ConvertFrom-SecureStringPlainText {
    param([Security.SecureString]$SecureValue)

    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    }
    finally {
        if ($pointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
        }
    }
}

Clear-Host
Write-Host "Thimaco financiële eigenaarbuild" -ForegroundColor Green
Write-Host ""
Write-Host "De activatiecode wordt cryptografisch willekeurig aangemaakt." -ForegroundColor Yellow
Write-Host "Schrijf de onderstaande code nu op papier. Maak geen screenshot en sla ze niet digitaal op." -ForegroundColor Yellow
Write-Host ""

$code = New-SecureRandomCode
Write-Host $code -ForegroundColor Cyan
Write-Host ""

$bevestigingSecure = Read-Host "Typ de code opnieuw om te bevestigen" -AsSecureString
$bevestiging = ConvertFrom-SecureStringPlainText -SecureValue $bevestigingSecure

try {
    if ($bevestiging.Trim().ToUpperInvariant() -ne $code) {
        Clear-Host
        throw "De bevestiging komt niet overeen. Voer het script opnieuw uit en noteer de nieuwe code zorgvuldig."
    }

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($code)
        $hashBytes = $sha256.ComputeHash($bytes)
        $hash = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
        [Array]::Clear($bytes, 0, $bytes.Length)
        [Array]::Clear($hashBytes, 0, $hashBytes.Length)
    }
    finally {
        $sha256.Dispose()
    }

    Clear-Host
    Write-Host "De papieren activatiecode is bevestigd." -ForegroundColor Green
    Write-Host "De code is uit dit terminalvenster verwijderd." -ForegroundColor Green
    Write-Host ""
    Write-Host "SHA-256-hash voor de eigenaarbuild:" -ForegroundColor Green
    Write-Host $hash -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Dart-defines voor uitsluitend jouw eigenaarbuild:" -ForegroundColor Green
    Write-Host "--dart-define=THIMACO_FINANCE_OWNER_BUILD=true"
    Write-Host "--dart-define=THIMACO_FINANCE_ACTIVATION_SHA256=$hash"
    Write-Host ""
    Write-Host "Normale personeelsbuild:" -ForegroundColor Green
    Write-Host "Gebruik geen van beide dart-defines. De financiële route wordt dan niet getoond."
    Write-Host ""
}
finally {
    $code = $null
    $bevestiging = $null
    $bevestigingSecure.Dispose()
}