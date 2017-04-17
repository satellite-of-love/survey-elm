module VersionInfo exposing (versionInfo)


type alias VersionInfo =
    { version : String }


versionInfo : VersionInfo
versionInfo =
    { version = "1.0.2" }
