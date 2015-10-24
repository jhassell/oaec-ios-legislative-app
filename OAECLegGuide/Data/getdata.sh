#!/bin/sh

wget -O CongressionalDistricts.json  "http://oklahomadata.org/boundary/1.0/boundary/?format=json&sets=congressional-districts&limit=10000"

wget -O StateHouseDistricts.json  "http://oklahomadata.org/boundary/1.0/boundary/?format=json&sets=state-house-districts&limit=10000"

wget -O StateSenateDistricts.json  "http://oklahomadata.org/boundary/1.0/boundary/?format=json&sets=state-senate-districts&limit=10000"

wget -O OAECRegions.json  "http://oklahomadata.org/boundary/1.0/boundary/?format=json&sets=oaec-regions&limit=10000"

