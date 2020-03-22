# mPulse
This shell script is designed to capture system runtime diagnostic data for investigating and troubleshooting the performance issues as well as Production impairments.

Something about the script
- The intention of this script is to reduce the manual efforts so that precious time can be saved during the impairment and so to mitigate the potential risk of human errors. 
- The shell script was originally written assuming that it will be used only for centOS/RedHat distros. Hence some features might not work on other linux flavors. Some minor tweaks can do the trick though. Source is open so help yourself :)
- This script captures System logs, System runtime, System information and recently added JVM diagnostics
- This is script is WIP and some features are not fool proof.
        
Future improvements
- JVM dump mechanism is very basic and does need tuning. Currecntly simultaneous JVM dump is not enabled. It might cost considerable amount of time if the jvm dump gets stuck due to unresponsive java VM.
