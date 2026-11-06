#!/bin/bash
###-------------------------------------------------------------------
### Author: Lukasz Opiola
### Copyright (C): 2023 ACK CYFRONET AGH
### This software is released under the MIT license cited in 'LICENSE.txt'.
###-------------------------------------------------------------------
### This script is called when the Onezone docker receives a termination
### signal. It makes sure that all system services of the Onezone instance
### are properly stopped, which is expected - as the graceful stop script
### should always be called before terminating the docker container.
###
### If it's not the case, displays a warning and attempts the graceful
### shutdown anyway, but in a typical containerized environment, the
### grace period may not be enough to finish it before the container
### is killed.
###-------------------------------------------------------------------

source /root/internal-scripts/common.sh

# indicates that graceful stop was already done; see common.sh
if [ -f ${GRACEFUL_STOP_LOCK_FILE} ]; then
    exit 0
else
    cat <<EOF
----------------------------------------------------------------------


                                 .i;;;;i.
                               iYcviii;vXY:
                             .YXi       .i1c.
                            .YC.     .    in7.
                           .vc.   ......   ;1c.
                           i7,   ..        .;1;
                          i7,   .. ...      .Y1i
                         ,7v     .6MMM@;     .YX,
                        .7;.   ..IMMMMMM1     :t7.
                       .;Y.     ;&MMMMMM9.     :tc.
                       vY.   .. .nMMM@MMU.      ;1v.
                      i7i   ...  .#MM@M@C. .....:71i
                     it:   ....   &MMM@9;.,i;;;i,;tti
                    :t7.  .....   0MMMWv.,iii:::,,;St.
                   .nC.   .....   IMMMQ..,::::::,.,czX.
                  .ct:   ....... .ZMMMI..,:::::::,,:76Y.
                  c2:   ......,i..Y&M@t..:::::::,,..inZY
                 vov   ......:ii..c&MBc..,,,,,,,,,,..iI9i
                i9Y   ......iii:..7@MA,..,,,,,,,,,....;AA:
               iIS.  ......:ii::..;@MI....,............;Ez.
              .I9.  ......:i::::...8M1..................C0z.
             .z9;  ......:i::::,.. .i:...................zWX.
             vbv  ......,i::::,,.      ................. :AQY
            c6Y.  .,...,::::,,..:t0@@QY. ................ :8bi
           :6S. ..,,...,:::,,,..EMMMMMMI. ............... .;bZ,
          :6o,  .,,,,..:::,,,..i#MMMMMM#v.................  YW2.
         .n8i ..,,,,,,,::,,,,.. tMMMMM@C:.................. .1Wn
         7Uc. .:::,,,,,::,,,,..   i1t;,..................... .UEi
         7C...::::::::::::,,,,..        ....................  vSi.
         ;1;...,,::::::,.........       ..................    Yz:
          v97,.........                                     .voC.
           izAotX7777777777777777777777777777777777777777Y7n92:
             .;CoIIIIIUAA666666699999ZZZZZZZZZZZZZZZZZZZZ6ov.

EOF

    dispatch-log "WARNING: detected a forced attempt to stop the Onezone service!"

    cat <<EOF
This may cause database inconsistencies or loss of recent changes of persistent data!

You should ALWAYS use the graceful stop procedure - call the
'/root/onezone-stop-graceful.sh' script BEFORE terminating the container.
Depending on the installation type, there are several ways to do that:

    * onedata-deployments - in the recent version (21.02.2+) of this repo,
      it is done automatically when using the 'onezone.sh stop' command.
      Make sure to pull the latest changes.

    * docker-compose - do not use 'docker-compose down' directly, precede
      it with calling the graceful stop script. If you have to use
      'docker-compose down', use the 'stop_grace_period' option set to a
      large value (e.g. '60m'). The default value of 10 seconds is
      way too low for a graceful shutdown.

    * docker - see above; do not use 'docker stop' directly, or provide
      the '--time' option with a large value. DO NOT use 'docker rm/kill'!

    * Kubernetes - provide the graceful stop script as the PreStop hook.

A graceful stop will now be attempted anyway.
If this process is SIGKILLed, the service persistence may get corrupted.
----------------------------------------------------------------------

EOF
fi

/root/internal-scripts/onezone-do-stop.sh
