# Fastly Demo
[![MIT license](http://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT) [![Discord Chat](https://img.shields.io/discord/299962468581638144.svg?logo=discord)](https://discord.gg/dw3Dam2)

Demonstrates using Terraform to dynamically configure DNS changes with Fastly pointing to AWS backends.

## Instructions
Configure AWS access keys and make sure Fastly api key is set to environment variable `FASTLY_API_KEY` for Terraform to be able to call the provider. 
```
$ git clone https://gitlab.com/antmounds/fastly-demo.git  # clones repo to current local directory
$ terraform init               	 	# downloads plugins and providers
$ terraform plan                	# displays the resources to be created/updated/destroyed
$ terraform apply                 	# launches 2 spot instances and a Fastly service
```

#### Variables - `variables.tf`
| *name* | *description* |
| ------ | ------ |
| **app_name** | Name of the service to tag resources with. |
| **domain_name** | Name of the wildcard or subdomain pointing to Fastly. |
| **owner** | Email of service owner. |

## Contributing
Pull requests, forks and stars are 太棒了 and mucho appreciatado!

- #### Get official Antmounds gear!
	<a href="https://streamlabs.com/Antmounds/#/merch">
		<img src="https://cdn.streamlabs.com/merch/panel8.png" width="160">
	</a>
	<a href="https://shop.spreadshirt.com/Antmounds">
		<img src="https://image.spreadshirtmedia.com/content/asset/sprd-logo_horizontal.svg" width="160">
	</a>

## Get in touch
* :speaking_head: Join the Antmounds [discord](https://discord.gg/VtFkvSv) server for more discussion and support on this project.

### MIT License
Copyright 2020-present Antmounds.com, Inc. or its affiliates. All Rights Reserved.

>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

>THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.