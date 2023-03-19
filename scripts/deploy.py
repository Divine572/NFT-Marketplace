from brownie import NFTMarketplace, accounts, config, network

def deploy_marketplace():
    # Load the account to deploy from
    dev = accounts.add(config["wallets"]["from_key"])
    print(f"Deploying from {dev.address}")

    # Deploy the contract
    marketplace = NFTMarketplace.deploy({"from": dev})

    print(f"NFTMarketplace contract deployed to {marketplace.address}")

def main():
    # Set the network to deploy to
    network_name = network.show_active()
    print(f"Deploying to {network_name} network")

    # Call the deploy function
    deploy_marketplace()
