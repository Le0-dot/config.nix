{
  lib,
  config,
  ...
}:

{
  config = lib.mkIf config.programs.television.enable {
    programs.television = {
      settings = {
        keybindings = {
          ctrl-d = "scroll_preview_half_page_down";
          ctrl-u = "scroll_preview_half_page_up";
        };
      };
      channels = {
        docker-containers = {
          metadata = {
            name = "docker-containers";
            description = "List and manage Docker containers";
            requirements = [
              "docker"
              "jq"
            ];
          };
          source = {
            command = [
              "docker ps --format '{{.Names}}\t{{.Status}}'"
              "docker ps -a --format '{{.Names}}\t{{.Status}}'"
            ];
            display = "{split:\t:0} ({split:\t:1})";
            output = "{split:\t:0}";
          };
          preview.command = "docker inspect '{split:\t:0}' | jq -C '.[0] | pick(.Name, .State, .Config)'";
          keybindings = {
            alt-s = [
              "actions:start"
              "reload_source"
            ];
            alt-k = [
              "actions:stop"
              "reload_source"
            ];
            alt-r = "actions:restart";
            alt-l = "actions:logs";
            alt-e = "actions:exec";
            alt-d = [
              "actions:remove"
              "reload_source"
            ];
          };
          actions = {
            start = {
              description = "Start the selected container";
              command = "docker start '{split:\t:0}'";
              mode = "fork";
            };
            stop = {
              description = "Stop the selected container";
              command = "docker stop '{split:\t:0}'";
              mode = "fork";
            };
            restart = {
              description = "Restart the selected container";
              command = "docker restart '{split:\t:0}'";
              mode = "fork";
            };
            logs = {
              description = "Follow logs of the selected container";
              command = "docker logs -f '{split:\t:0}'";
              mode = "execute";
            };
            exec = {
              description = "Execute shell in the selected container";
              command = "docker exec -it '{split:\t:0}' /bin/sh";
              mode = "execute";
            };
            remove = {
              description = "Remove the selected container";
              command = "docker rm -f '{split:\t:0}'";
              mode = "fork";
            };
          };
        };
        docker-volumes = {
          metadata = {
            name = "docker-volumes";
            description = "List and manage Docker volumes";
            requirements = [
              "docker"
              "jq"
            ];
          };
          source = {
            command = "docker volume ls --format '{{.Name}}\t{{.Driver}}'";
            display = "{split:\t:0} ({split:\t:1})";
            output = "{split:\t:0}";
          };
          preview.command = "docker volume inspect '{split:\t:0}' | jq -C '.[0]'";
          keybindings = {
            alt-d = [
              "actions:remove"
              "reload_source"
            ];
          };
          actions = {
            remove = {
              description = "Remove the selected volume";
              command = "docker volume rm '{split:\t:0}'";
              mode = "fork";
            };
          };
        };
        git-branch = {
          metadata = {
            name = "git-branch";
            description = "A channel to select from git branches";
            requirements = [ "git" ];
          };
          source = {
            command = [
              "git --no-pager branch --sort=-committerdate --format='%(refname:short)'"
              "git --no-pager branch --sort=-committerdate --all --format='%(refname:short)'"
            ];
            no_sort = true;
            output = "{}";
          };
          preview = {
            command = "git log --color=always '{}'";
          };
          keybindings = {
            space = "actions:switch";
            enter = "actions:log";
            alt-d = "actions:delete";
            alt-r = "actions:rebase";
          };
          actions = {
            switch = {
              description = "Checkout the selected branch";
              command = "git switch '{}'";
              mode = "fork";
            };
            log = {
              description = "Checkout the selected branch";
              command = "git switch --detach '{}' && tv git-log && git switch -";
              mode = "execute";
            };
            delete = {
              description = "Delete the selected branch";
              command = "git branch -d '{}'";
              mode = "execute";
            };
            rebase = {
              description = "Rebase current branch onto the selected branch";
              command = "git rebase '{}'";
              mode = "execute";
            };
          };
        };
        git-worktree = {
          metadata = {
            name = "git-worktree";
            description = "List and manage git worktrees";
            requirements = [
              "git"
              "awk"
            ];
          };
          source = {
            command = ''
              git worktree list --porcelain \
                | awk 'BEGIN {RS=""; OFS="\t"} {
                    n = split($2, segments, "/"); 
                    sub(/^refs\/heads\//, "", $6); 
                    print segments[n], $6
                  }'
            '';
            display = "{split:\t:1}: {split:\t:0}";
            output = "{split:\t:0}";
          };
          preview = {
            command = "git log --oneline --color=always '{split:\t:1}'";
          };
          keybindings = {
            alt-d = "actions:remove";
          };
          actions = {
            remove = {
              description = "Remove worktree and branch";
              command = "git worktree remove '{split:\t:0}' && git branch --delete '{split:\t:1}'";
              mode = "execute";
            };
          };
        };
        jira-tickets = {
          metadata = {
            name = "jira-tickets";
            description = ''
              List and manage jira tickets. 
              The following environment variables should be set: 
                - ATLASSIAN_SERVER_URL
                - JIRA_API_TOKEN
                - JIRA_BRANCH_FORMAT
            '';
            requirements = [
              "jq"
              "git"
              "curl"
            ];
          };
          source = {
            command = ''
              curl -u $(git config user.email):$JIRA_API_TOKEN \
                --variable jql="assignee = currentUser() and status != 'CLOSED'" \
                --variable fields="key,summary" \
                --expand-url "$ATLASSIAN_SERVER_URL/rest/api/3/search/jql?jql={{jql:url}}&fields={{fields:url}}" \
                | jq -r '.["issues"][] | [.key, .fields.summary] | join("\t")'
            '';
            display = "{split:\t:0}: {split:\t:1}";
            output = "{split:\t:0}";
          };
          keybindings = {
            alt-b = "actions:browse";
            alt-w = "actions:worktree";
          };
          actions = {
            browse = {
              description = "Open jira ticket in web browser";
              command = "xdg-open $ATLASSIAN_SERVER_URL/browse/'{split:\t:0}'";
              mode = "execute";
            };
            worktree = {
              description = "Create branch and worktree in current git repository for the ticket";
              command = ''
                root="$(git rev-parse --show-toplevel)"
                dir="$(echo '{split:\t:1}' | tr 'A-Z' 'a-z' | tr -s ' ' '-' | tr -dc 'a-z0-9-')"
                branch=$(printf $JIRA_BRANCH_FORMAT '{split:\t:0}')
                git worktree add "$root/../$dir" -b "$branch"
              '';
              mode = "execute";
            };
          };
        };
      };
    };
  };
}
