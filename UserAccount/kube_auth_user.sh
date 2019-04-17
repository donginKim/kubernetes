#!/bin/bash


#
# create kubernetes pod create user
#

#create Service Account user
echo -e "Set User Name : \c"
read user
kubectl create serviceaccount $user

#create Cluster Role Account
echo -e "Add Cluster Role (verb) : \c"
read -a roles

echo -e "Add Cluster Resource : \c"
read -a namespaces

verbs=""
for VERB in "${roles[@]}";
do verbs=$verbs" --verb="$VERB
done

resources=""
for RESOURCE in "${namespaces[@]}";
do resources=$resources" --resource="$RESOURCE
done

kubectl create clusterrole $user $resources $verbs

#create Cluster Role Binding
kubectl create clusterrolebinding $user \
	--serviceaccount=default:$user \
	--clusterrole=$user

#Get Token Role
TOKEN=$(kubectl describe secrets "$(kubectl describe serviceaccount $user | grep -i Tokens | awk '{print $2}')" | grep token: | awk '{print $2}')

#Kubectl Config Set Credentials
kubectl config set-credentials $user --token=$TOKEN

#Kubectl Config Set Context
kubectl config set-context $user --cluster=$(kubectl config current-context) --user=$user

#Kubectl Config Use Context
echo -e "Use $user Context ? (y/n) : \c"
read answer

if [ $answer = "y" ]; then
 echo "Use $user Context."
 kubectl use-context $user
 echo -e "Do you want Check Access Permission ? (y/n) : \c"
 read answerP
 if [ $answerP = "y" ]; then
  echo -e "Please enter the command to check authority: \c"
  read premissionC
  check_Permission $permissionC
 fi
fi

if [ $answer = "n" ]; then
 echo "Don't Use $user Context."
fi

#Check Access Permission
function check_Permission(){
 local value=$1
 kubectl auth can-i ${value}
}
