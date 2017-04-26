module VersionInfo exposing (versionInfo)

-- TODO: add release date and time


type alias VersionInfo =
    { version : String }


versionInfo : VersionInfo
versionInfo =
    { version = "1.0.10" }
