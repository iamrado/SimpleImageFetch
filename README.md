
# SimpleImageFetch
A very simple image fetcher for iOS that can be used to fetch images in scrollable content. Not meant to be used in production as there are other solutions with far better performance available.

Photos are downloaded from https://picsum.photos.

# Architecture
The whole solution is built around **ImageFetcher** class which provides an interface to fetch and cancel in progress operations. It uses in memory cache to store already donwloaded photos.

Each url has it's corresponding **ImageRequestTask** which is responsible for fetching the data, decoding into UIImage and resize to smaller size. The resizing is currently set to a fixed size but could be extended in the feature.

There is a convenient category for **UIImageView** to set an image from url. This is the entry point for UITableView or UICollectionView use. ObjC runtime features are used to set and get associated object which helps identify what *URL* is assiciated which what UIImageView.

## Usage Example
```
let model // your model representing single cell
cell.iamgeView.setImage(withURL: model.imageURL)

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ...
    
    let photo = photos[indexPath.row]
    cell.photoView.setImage(withURL: photo.downloadUrl)

    ...
}
```

# Demo
https://user-images.githubusercontent.com/610622/113020481-8cd8fb00-917a-11eb-9efb-f60f9233c167.mov
