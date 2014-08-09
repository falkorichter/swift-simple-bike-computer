swift-simple-bike-computer
===========================

swift code to read out a BTLE "Cycling Speed and Cadence" sensor following the specification at https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.cycling_speed_and_cadence.xml

currently reads out the values and logs them.

The goal is to add a simple interface to:

* show current speed
* show total speed
* show trip distance
* show trip average speed
* show max speed

since btle frameworks are available both on mac and iPhone, this project will try to be as much as multi platform as possible. I know that you propably will not mount your mac on your bike to use it as a bike computer :)

