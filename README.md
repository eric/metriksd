# Metriks Server

An experimental server for ruby metrics library called [metriks][].

## Highlights

* Similar to [statsd][]
  * Receives data via UDP
  * Aggregates results from multiple data points and sends batches to a datastore
* Receives metrics as a snappy-encoded packet of msgpack'd hashes
* Each packet can contain more than one metric
* Intended to be used with [metriksd_reporter][] and [metriks][]

## Usage

Run the server:

    $ metriksd -c config.yml



# License

Copyright (c) 2012 Eric Lindvall

Published under the MIT License, see LICENSE

[statsd]: https://github.com/etsy/statsd
[metriks]: https://github.com/eric/metriks
[metriksd_reporter]: https://github.com/eric/metriksd_reporter
