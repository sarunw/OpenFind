//
//  PhotosSlidesInfoView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import SwiftUI

struct PhotosSlidesInfoView: View {
    @ObservedObject var model: PhotosViewModel
    var body: some View {
        let photo = model.slidesState?.currentPhoto ?? Photo(asset: PHAsset())

        VStack(alignment: .leading) {
            Text(verbatim: "\(photo.asset.originalFilename ?? "Photo")")

            Text(verbatim: "\(getDateString(from: photo))")
                .padding(12)
                .frame(maxWidth: .infinity)
                .blueBackground()

            HStack {
                let ignored = photo.metadata?.isIgnored ?? false

                if !ignored {
                    let scanState = getScanState(from: photo)
                    PhotosScanningInfoButton(
                        title: scanState.1,
                        isOn: scanState.0
                    ) {
                        print("Scan now")
                    }
                    .transition(.scale)
                }

                PhotosScanningInfoButton(
                    title: ignored ? "Ignored" : "Ignore",
                    isOn: ignored
                ) {
                    var newPhoto = photo
                    let isIgnored = !ignored
                    if newPhoto.metadata != nil {
                        newPhoto.metadata?.isIgnored = isIgnored
                        withAnimation {
                            model.updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                        }
                    } else {
                        let metadata = PhotoMetadata(
                            assetIdentifier: photo.asset.localIdentifier,
                            sentences: [],
                            dateScanned: nil,
                            isStarred: false,
                            isIgnored: isIgnored
                        )
                        newPhoto.metadata = metadata
                        withAnimation {
                            model.updatePhotoMetadata(photo: newPhoto, reloadCell: true)
                        }
                    }
                }
            }
        }
        .foregroundColor(.accent)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(16)
        .edgesIgnoringSafeArea(.all)
    }

    func getDateString(from photo: Photo) -> String {
        if let date = photo.asset.creationDate {
            return date.dateTimeFormat
        }
        return ""
    }

    /// 1. is scanned or not
    /// 2. title
    func getScanState(from photo: Photo) -> (Bool, String) {
        if let metadata = photo.metadata, metadata.dateScanned != nil {
            return (true, "Scanned")
        }
        return (false, "Scan Now")
    }
}

struct PhotosScanningInfoButton: View {
    let title: String
    let isOn: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isOn ? .white : .accent)
                .frame(maxWidth: .infinity)
                .padding()
                .blueBackground(highlighted: isOn)
        }
    }
}

extension Date {
    var dateTimeFormat: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "MMM d, yyyy' at 'h:mm a"
        let string = formatter.string(from: self)
        return string
    }
}