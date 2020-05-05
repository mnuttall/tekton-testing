Testing the use of 'hub' in a Tekton task to automerge a pull request

```sh
docker build -t mnuttall/hub-test .
docker push mnuttall/hub-test
```

Now set up a pull request we'd like to merge.

For example in my clone of rhd-gitops-example.services/tmp,

```
../services promote --from promote-demo --to https://github.com/mnuttall/gitops-example-dev.git --service promote-demo --debug
2020/04/27 10:29:25 created PR Link=https://github.com/mnuttall/gitops-example-dev/pull/13.diff Source=promote-demo-local-dir-4e1e3 Target=master
```



Modify config/pullrequest.yaml for the new PR

# Set up Tekton resources

```sh
kubectl create configmap promoteconfigmap --from-file=gitconfig
```

Run the pipeline:

```sh
tkn pipeline start automerge-pipeline -r source-repo=gitops-repo -r pr=pull-request -p github-config=promoteconfigmap -p github-secret=github-secret --showlog
```

This will merge the Pull Request and delete the branch it was associated with.

# Webhooks support

Tasks previously in 'config' moved to 'standalone'. GitHub Enterprise and Tekton Webhooks support requires some changes to the task, plus the creation of TriggerTemplates and Bindings. See webhooks/ directory. 

Set up Tekton Dashboard webhooks extension and then initiate with code of the form, 

```
~/dev/goprojects/src/github.com/rhd-gitops-example/services/services promote --from promote-demo --to https://github.ibm.com/mnuttall/gitops-example-dev.git --service promote-demo --debug --commit-message "Tuesday.1" --repository-type ghe
2020/05/05 10:17:19 created PR 8
```
