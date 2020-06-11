# tableau-reports  
## Annual Report Sample
This is the pdf ouput of a tableau workbook for one child advocacy center. These reports are to give each of eleven centers a set of charts with data that are routinely requested by different sources.
The master workbook has a parameter for year and center that controls what is diplayed in the report.

## Map with selectable paramters
This packaged workbook is a vicualization of MS counties and reports on either the number of children receiving a service is a given year or the rate/1000 children in the county. 

## Growth and Development Maps
This is a a first draft of an ongoing project seeking to better understand the nature of Child advocacy center service areas, identify locations for new centers, and possibly realign existing service areas.
The 40&60 Mile Radius maps displays cac service areas by whether or not the county boundaries are entirely, partially, or not within a 40/60 mile radius of the office serving the area.
The distance caluclation were done in R with using a shape file of MS counties, the coordinates for cac ofice locations, and the geospere package.

The other two maps, show some basic demographic and child protection data by service area and county.

Next steps are to:
1) Identify metropolitan areas in the unserved counties and calcaulate the optimal distribution of new CACs to ensure all counties are covered.
2) Attempt to use google map api and adjust 60 miles radius to 1 hour drive time using shapefiles of county polygons and federal, state, and county roads.


See radius_maps_sample.R for radius calculations
