<template>
  <NuxtPage />

  <Notification />
</template>


<script setup>


let { init, web3, connectedAccount, contract, contractAddress } = useAuctionState();

onMounted(async () => {
    await init();
    console.log("Web3: ", web3.value);
    console.log("Connected Account: ", connectedAccount.value);
    console.log("Contract: ", contract.value);
    console.log("Contract Address: ", contractAddress.value);


});

// let { notificationStack } = useAuctionState();
// function sendNotification() {
//   notificationStack.value.push({
//     id: Math.random().toString(36).substr(2, 9),
//     message: 'New bid received!',
//   });
// }


</script>