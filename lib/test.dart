import 'package:dio/dio.dart';

void fetchNFTs() async {
  final dio = Dio();

  final url =
      'https://eth-mainnet.g.alchemy.com/nft/v3/9jpBHMXkEz6T9y1izafF5i3f-RAnSDhJ/getNFTsForOwner?owner=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045&withMetadata=true&pageSize=100';

  try {
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );

    print(response.data); // JSON data from the API
  } catch (e) {
    print('Error fetching NFTs: $e');
  }
}

void main() {
  fetchNFTs();
}
