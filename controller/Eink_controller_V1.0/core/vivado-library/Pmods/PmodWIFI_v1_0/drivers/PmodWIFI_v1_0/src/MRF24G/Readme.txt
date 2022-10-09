WiFiShieldOrPmodWiFi_G WiFi Network Hardware Library for the MRF24WG (not to be confused with MRF24WB0MA)

1.  To install this library refer to the instructions at ...\libraries\DNETcK\Readme.txt
2.  By default, the WiFiShieldOrPmodWiFi works with the following configurations.

        Uno32 with WiFi Shield								
        Uno32 with PmodShield and PmodWiFi on connector JC	
        Max32 with WiFi Shield								
        Max32 with PmodShield and PmodWiFi on connector JC	
        MX3cK with PmodWiFi on connector JE					
        MX4ck with PmodWiFi on connector JB 				
        32MX4 with PmodWiFi on connector JB 				
        MX7ck with PmodWiFi on connector JF 				
        32MX7 with PmodWiFi on connector JF 				

3.  Include in your sketch WiFiShieldOrPmodWiFi_G.h before you include DNETcK.h. Include DNETcK before you include DWIFIcK.h
    This network hardware library only works with WiFi.
4.  Then build and run DNETcK/DWIFIcK as documented in ..\libraries\DNETcK\documents\DNETcK.pdf and ..\libraries\DWIFIcK\documents\DWIFIcK.pdf
5.  Also refer to the WiFi example sketches under ...\libraries\DWIFIcK\examples