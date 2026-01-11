//
//  SelectableRow.swift
//  Nevvi
//
//  Created by Tyler Standal on 1/11/26.
//

import SwiftUI

struct SelectableRow: View {
    let title: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection indicator
                Group {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(isSelected ? ColorConstants.primary : .secondary)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? ColorConstants.primary : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? ColorConstants.primary.opacity(0.08) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isSelected ? ColorConstants.primary.opacity(0.3) : Color(.systemGray5),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview {
    SelectableRow(title: "Test", isSelected: true) {
        
    }
}
