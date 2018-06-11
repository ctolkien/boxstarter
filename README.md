# About this project

This is my personal boxstarter script

This is based on these projects

- Boxstarter [boxstarter.org](http://boxstarter.org)
- Chocolatey [chocolatey.org](http://chocolatey.org)
- Windows Dev Box setup (https://github.com/Microsoft/windows-dev-box-setup-scripts)

## How to run the scripts

To run a setup script, click a link in the table below from your target machine. This will download Boxstarter, and prompt you for Boxstarter to run with Administrator privileges (which it needs to do its job). Clicking yes in this dialog will cause the script to begin. You can then leave the job unattended and come back when it's finished.

| Click link to run                                                                                                                    | Description   |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------- |
| <a href='http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/RobCannon/boxstarter/master/dev_box.ps1'>dev_box</a> | My Boxstarter |

#### Setup up WSL via curl

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/RobCannon/boxstarter/master/boxstarter.sh)"
```
