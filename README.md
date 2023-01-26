#remover repos Github Account
==============

Ruby script to delete repo list from your github account.

## Usage


```
$ ruby remover.rb -t <token> -r <repos-file>
```

Example:

```
$ ruby remover.rb  -t fake_bearer_token_ghp_dhqhJ -r custom_file.txt
```

### Notes

- To get token create one from https://github.com/settings/tokens/new
- If your file list is empty then script get all repost thar you can delete but if file list contain at least one line then the script delete these repos
- Remember run `bundle` to install dependencies