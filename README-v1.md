# cigarette

Tiny test tool.

This README is for cigarette 1.* versions (without RVM management).

## Requirements

You need rubygems installed.

Tested with Ruby:

* 1.8.7
* 1.9.2
* 1.9.3
* 2.0.0-preview1

## Installation

    gem install cigarette

or

    git clone https://github.com/TibshoOT/cigarette.git

## Configuration

In order to smoke or run cigarette, you need to create a .cigarette file binary call directory.

For example, you need to test your app in /home/lucky/app:

    $ cd /home/lucky/app
    $ touch .cigarette
    [fill needed options]
    $ cigarette

That's it.

### .cigarette file (YAML)

At the moment, there is only two options:

<table>
  <tr>
    <th>Attribute</th>
    <th>Argument</th>
    <th>Explanation</th>
  </tr>
  <tr>
    <th>each</th>
    <td>Period between run</td>
    <td>Time between command run (in second)</td>
  </tr>
  <tr>
    <th>command</th>
    <td>a command to execute</td>
    <td>This command will be exectued each :each configuration</td>
  </tr>
</table>

Example:

    $ cat .cigarette

You should see:

    each: 75
    command: 'rake test'

'rake test' will be executed each 75 seconds.

### Time helper

For each attribute, you can use period helper.

<table>
  <tr>
    <th>Helper</th>
    <th>Example</th>
    <th>Equivalent without helper</th>
  </tr>
  <tr>
    <th>second</th>
    <td>2.second</td>
    <td>2</td>
  </tr>
  <tr>
    <th>minute</th>
    <td>5.minute</td>
    <td>300</td>
  </tr>
  <tr>
    <th>hour</th>
    <td>1.hour</td>
    <td>3600</td>
  </tr>
</table>

Example:

    $ cat .cigarette

You should see:

    each: 2.minute
    command: 'rake test'

You can pluralize these helpers (seconds, minutes, hours).

    each: 5.hours

## Usage

Go to containing .cigarette file directory and run cigarette:

    $ cd your/directory
    $ cigarette

Enjoy.

## Want a feature ? Problem ?

Open an issue ;)
