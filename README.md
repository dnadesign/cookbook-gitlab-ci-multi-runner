# gitlab-ci-multi-runner-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitlab-ci-multi-runner']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### gitlab-ci-multi-runner::default

Include `gitlab-ci-multi-runner` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[gitlab-ci-multi-runner::default]"
  ]
}
```

## License and Authors

Author:: Jeremy Olliver (<jeremy.olliver@gmail.com>)
