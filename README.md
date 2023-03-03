axs2kilt (pronounced like "Access to KILT")
===============================================

In this repository we keep [axs](https://github.com/krai/axs) entries related to KILT.

To import this repository and its dependencies into your **work_collection** , run
```
axs byquery git_repo,collection,repo_name=axs2kilt && \
axs byquery git_repo,collection,repo_name=axs2mlperf
```

Running BERT 99 with `kilt`.
```
axs byquery compiled,protobuf &&\
axs byquery tokenized,squad_v1_1,calibration=yes &&\
axs byquery bert_squad,qaic,framework=kilt,model_name=bert_99
```

Verify accuracy
```
axs byquery bert_squad,qaic,framework=kilt,model_name=bert_99_9 , get accuracy_dict
```
