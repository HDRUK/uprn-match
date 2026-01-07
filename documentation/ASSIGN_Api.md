# UPRN-ASSIGN API

## An interface that allows a user to post an address candidate, that reponds with a UPRN and other meta data.

```
curl -u {username}:{password} {endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA
{"Address_format":"good","Postcode_quality":"good","Matched":true,"UPRN":"100023336956","Qualifier":"Best (residential) match","Classification":"RD04","ClassTerm":"Terraced","Algorithm":"10-match1","ABPAddress":{"Number":"10","Street":"Downing Street","Town":"City Of Westminster","Postcode":"SW1A 2AA"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}
```

```
>>> import requests
>>> resp = requests.get('{endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA', auth=({username}, {password}))
>>> resp_dict = resp.json()
>>> print(resp_dict.get('UPRN'))
100023336956
>>> resp
<Response [200]>
>>> resp.text
'{"Address_format":"good","Postcode_quality":"good","Matched":true,"UPRN":"100023336956","Qualifier":"Best (residential) match","Classification":"RD04","ClassTerm":"Terraced","Algorithm":"10-match1","ABPAddress":{"Number":"10","Street":"Downing Street","Town":"City Of Westminster","Postcode":"SW1A 2AA"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}\n'
```

The getinfo route now supports an optional commercial parameter that controls whether the search is residential, commercial, or neutral based on a bit pattern.

## API Behavior

If the commercial parameter is not provided, the API defaults to a residential search.

For a neutral search, the system applies the following selection logic to determine the UPRN.

Given an address candidate, the algorithm selects the first matching UPRN using the following priority order:

1. If the UPRN classification code is *residential*, it is selected.
2. Otherwise, if the classification code is *commercial*, it is selected.

Bit Pattern Values

* `100` — Residential search
* `010` — Commercial search
* `001` — Neutral search

Examples

Commercial Search
```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA&commercial=010"
```

Neutral Search
```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA&commercial=001"
```

Residential Search (Explicit)
```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=10+Downing+St,Westminster,London,SW1A2AA&commercial=100"
```

Residential Search (Default)
If the `commercial` parameter is omitted, the API automatically performs a *residential* search.

## More examples

Commercial Search

```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=8,Batchelor+Street,ME4+4BJ&commercial=010"
{"Address_format":"good","Postcode_quality":"good","Matched":true,"BestMatch":{"UPRN":"44052106","Qualifier":"Property","LogicalStatus":"1","Classification":"CR07","ClassTerm":"Restaurant \/ Cafeteria","Algorithm":"1-match","ABPAddress":{"Number":"8","Street":"Batchelor Street","Town":"Medway","Postcode":"ME4 4BJ"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}}
```

Residential Search (Explicit)

```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=8,Batchelor+Street,ME4+4BJ&commercial=100"
{"Address_format":"good","Postcode_quality":"good","Matched":true,"BestMatch":{"UPRN":"44012081","Qualifier":"Property","LogicalStatus":"1","Classification":"RD06","ClassTerm":"Self Contained Flat (Includes Maisonette \/ Apartment)","Algorithm":"1-match","ABPAddress":{"Flat":"flat","Number":"8","Street":"Batchelor Street","Town":"Medway","Postcode":"ME4 4BJ"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}}
```

Neutral Search
```
curl -u {username}:{password} "{endpoint}/api2/getinfo?adrec=8,Batchelor+Street,ME4+4BJ&commercial=001"
{"Address_format":"good","Postcode_quality":"good","Matched":true,"BestMatch":{"UPRN":"44012081","Qualifier":"Property","LogicalStatus":"1","Classification":"RD06","ClassTerm":"Self Contained Flat (Includes Maisonette \/ Apartment)","Algorithm":"1-match","ABPAddress":{"Flat":"flat","Number":"8","Street":"Batchelor Street","Town":"Medway","Postcode":"ME4 4BJ"},"Match_pattern":{"Postcode":"equivalent","Street":"equivalent","Number":"equivalent","Building":"equivalent","Flat":"equivalent"}}}
```

## An interface that allows a user to upload a file of address candidates, that are processed immediately, after the file has been uploaded.

The address file to be uploaded must contain two columns separated by a single tab character with a .txt extension

The first line must not contain any header information

The first column is a unique numeric row id

The second column is an address string including a postcode at the end with a comma separating the address from the postcode

The third column is the postal region (not mandatory, but useful when you don't know the address candidates postcode)

The fourth column specifies the type of search the system should perform for the address candidate on the same row

## Fourth Column Values

C - Performs a commercial search

N - Performs a neutral search

Any other value or blank - Defaults to a residential search

If an older TSV file is used that does not include the fourth column, the system will automatically perform a residential search by default.

Example records:
```
1[tab]10 Downing St,Westminster,London,SW1A2AA[tab]SW[tab]C
2[tab]10 Downing St,Westminster,London[tab]SW[tab]N
3[tab]Bridge Street,London,SW1A 2LW[tab][tab]R
4[tab]221b Baker St,Marylebone,London,NW1 6XE[tab]NW
5[tab]3 Abbey Rd,St John's Wood,London,NW8 9AY[tab]NW[tab]
```

```
curl -u {username}:{password} -i -X POST -H "Content-Type: multipart/form-data" -F "file=@D:\test_in.txt" {endpoint}/api2/fileupload2
```

```
>>> url = '{endpoint}/api2/fileupload2'
>>> files = {'file': ('test.txt', open('D://test_in.txt', 'rb'), 'text/plain')} 
>>> r = requests.post(url, files=files, auth=('{username}', '{password}'))
>>> r.text
'{"upload": { "status": "OK"}}\n'
```

## An interface that allows a user to download a previously uploaded file.

```
curl -u {username}:{password} "{endpoint}/api2/download3?filename=paul.txt" --output "d:\test_out.txt"
```

```
>>> r = requests.get('{endpoint}/api2/download3?filename=test.txt', auth=('{username}', '{password}'))
>>> text_file = open("d:\\test_out.txt", "w")
>>> text_file.write(r.text)
>>> text_file.close()
```