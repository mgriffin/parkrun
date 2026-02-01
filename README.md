# How long does it take

To drive between all the Parkrun courses in Mayo

Read more about why at https://mikegriffin.ie/blog/20260131-all-the-parkruns-in-mayo-in-one-day

### Output

```bash
$ bundle exec sequel -m db/migrations sqlite://db/parkrun.sqlite
$ ruby calc.rb
Getting county information
Calculating distances
Westport parkrun to Castlebar parkrun is 17km
Westport parkrun to Ballina parkrun is 59km
Westport parkrun to Erris parkrun is 90km
Westport parkrun to Claremorris parkrun is 46km
Westport parkrun to Achill Greenway parkrun is 43km
Westport parkrun to Tourmakeady Wood parkrun is 27km
Castlebar parkrun to Ballina parkrun is 37km
Castlebar parkrun to Erris parkrun is 85km
Castlebar parkrun to Claremorris parkrun is 29km
Castlebar parkrun to Achill Greenway parkrun is 48km
Castlebar parkrun to Tourmakeady Wood parkrun is 30km
Ballina parkrun to Erris parkrun is 73km
Ballina parkrun to Claremorris parkrun is 52km
Ballina parkrun to Achill Greenway parkrun is 77km
Ballina parkrun to Tourmakeady Wood parkrun is 68km
Erris parkrun to Claremorris parkrun is 112km
Erris parkrun to Achill Greenway parkrun is 73km
Erris parkrun to Tourmakeady Wood parkrun is 117km
Claremorris parkrun to Achill Greenway parkrun is 86km
Claremorris parkrun to Tourmakeady Wood parkrun is 42km
Achill Greenway parkrun to Tourmakeady Wood parkrun is 69km
Calculating permutations
The shortest driving distance is 250km for Ballina, Castlebar, Claremorris, Tourmakeady Wood, Westport, Achill Greenway, Erris, which would take 4 hours, 16 minutes
The longest driving distance is 490km for Castlebar, Achill Greenway, Claremorris, Erris, Tourmakeady Wood, Ballina, Westport, which would take 7 hours, 50 minutes, 17 seconds
```
