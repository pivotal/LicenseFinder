Set-PSDebug -strict # "set -u"
$ErrorActionPreference = "Stop" # "set -e" for cmdlet errors

# avoid overly narrow default linewrap
$term = (get-host).ui.rawui
$size = $term.buffersize
$size.width = 128
$term.buffersize = $size
$size = $term.windowsize
$size.width = 128
$term.windowsize = $size

function stream-cmd {
    param ($command, $arguments)
    $cmdline = "$($command) $($arguments)"
    cmd /c $cmdline
    if (-not ($?)) {
        throw "$($cmdline) failed"
    }
}

function prepend-path {
    param ($dir)
    $env:PATH = $dir + ";" + $env:PATH
}

function prepare-vm {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install -y git ruby nodejs golang python2 erlang gradle maven
    
    $env:JAVA_HOME = 'C:\Program Files\Java\jdk1.8.0_144'
    prepend-path 'C:\Program Files\Java\jdk1.8.0_144\bin'
    prepend-path 'C:\tools\go\bin'
    prepend-path 'C:\Program Files\Git\bin'
    prepend-path 'C:\Program Files\erl9.0\bin'
    stream-cmd "rmdir" "/s /q C:\rebar"
    stream-cmd "git" "clone https://github.com/rebar/rebar C:\rebar"
    stream-cmd "cd c:\rebar & .\bootstrap.bat" ""
    stream-cmd "cp" "c:\rebar\rebar c:\tools"
    stream-cmd "cp" "c:\rebar\rebar.cmd c:\tools"
    prepend-path 'C:\tools'
    mkdir -Force 'C:\Go'
    mkdir -Force 'C:\Windows\system32\config\systemprofile\AppData\Local\Temp'
    $env:GOPATH = 'C:\Go'
    prepend-path 'C:\Go\bin'
    stream-cmd "go" "get -d github.com/tools/godep"
    prepend-path 'C:\Python27\Scripts'
    prepend-path 'C:\Program Files\nodejs'
    stream-cmd "npm" "install bower -g"
    cp 'C:\Windows\System32\config\systemprofile\AppData\Roaming\npm\bower.cmd' 'C:\Program Files\nodejs'
    cp -r 'C:\Windows\System32\config\systemprofile\AppData\Roaming\npm\node_modules\bower\*' 'C:\Program Files\nodejs\node_modules\bower' -Force
    prepend-path 'C:\Ruby23\bin'
    prepend-path 'C:\ProgramData\chocolatey\lib\gradle\tools\gradle-3.4.1\bin'
    prepend-path 'C:\ProgramData\chocolatey\lib\maven\apache-maven-3.5.0\bin'
}

function set-env-vars {
    prepend-path 'C:\Program Files\Java\jdk1.8.0_144\bin'
    prepend-path 'C:\tools\go\bin'
    prepend-path 'C:\Program Files\Git\bin'
    prepend-path 'C:\Program Files\erl9.0\bin'
    prepend-path 'C:\tools'
    prepend-path 'C:\Go\bin'
    prepend-path 'C:\Python27\Scripts'
    prepend-path 'C:\Program Files\nodejs'
    prepend-path 'C:\Ruby23\bin'
}

function run-tests {
    set-env-vars
    push-location LicenseFinder
        stream-cmd "gem" "install bundler"
        stream-cmd "bundle" "install"
        stream-cmd "bundle" "exec rake install"
        stream-cmd "bundle" "exec rake spec"
        stream-cmd "bundle" "exec rake features"
    pop-location
}

prepare-vm
run-tests
