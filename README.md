# Kong Axiomatics

A plugin that integrates Kong with an Axiomatics PDP endpoint.

## Description

Before proxying the request to an API upstream of Kong, this plugin will send a XACML JSON POST request to an Axiomatics PDP endpoint and based on the response determine whether to proceed or return.

## Installation

### With a local instance of Kong

Clone this repo

<pre>
$ git clone https://github.com/ioannis-iordanidis/kong-axiomatics-plugin
$ cd kong-axiomatics-plugin
$ luarocks make *.rockspec
</pre>

You will also have to add the kong-axiomatics-plugin in your configuration file.
If you are starting from the default kong.conf file uncomment the plugins key and add this one

<pre>
plugins = bundled, kong-axiomatics-plugin
</pre>

Restart Kong using this configuration file and you're ready to go

<pre>
kong stop
kong start -c /etc/kong/kong.conf
</pre>

### With docker

Build and start Kong

<pre>
docker-compose build --force-rm && docker-compose up -d
</pre>

Stop Kong as well as remove Docker volume to be able to start from scratch

<pre>
docker-compose down -v
</pre>

## Configuration

<table><thead>
<tr>
<th>form parameter</th>
<th>default</th>
<th>description</th>
</tr>
</thead><tbody>
<tr>
<td><code>config.pdp_url</code><br><em>required</em></td>
<td></td>
<td>The URL to which the plugin will make a JSON <code>POST</code> request before proxying the original request.</td>
</tr>
<tr>
<td><code>config.token_header_name</code><br><em>required</em></td>
<td>Authorization</td>
<td>The name of the header that carries the JWT</td>
</tr>
<tr>
<td><code>config.claims_to_include</code></td>
<td></td>
<td>A list of strings that correspond to the claims we are interested in forwarding to the PDP from the JWT</td>
</tr>
</tbody></table>

## Author
Ioannis Iordanidis

## License
<pre>
The MIT License (MIT)
=====================

Copyright (c) 2019 Ioannis Iordanidis

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
</pre>
