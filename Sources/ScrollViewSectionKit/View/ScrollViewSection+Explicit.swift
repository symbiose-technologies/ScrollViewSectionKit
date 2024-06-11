//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 3/26/24
//
////////////////////////////////////////////////////////////////////////////////

import Foundation

import SwiftUI

/// The `ScrollViewSection` is a view that represents a section in a `ScrollView` SwiftUI component.
///
/// You can customize the appearance of the section by applying a `ScrollViewSectionStyle` by using function [`.scrollViewSectionBackgroundColor(_ color: Color)`](x-source-tag://Function_ScrollViewSectionBackgroundColor) .
/// By default, the `insetGrouped` will be used.
///
/// - Example:
///
///         var body: some View {
///             ScrollView {
///                 VStack(spacing: 0.0) {
///                     ScrollViewSection {
///                         Text("First row")
///                         Text("Second row")
///                         Text("Third row")
///                     }
///                 }
///             }
///         }
///
/// In the example above, `ScrollViewSection` is used to group the three `Text` views together in a section.
///
/// The `ScrollViewSection` supports a header and footer view, which can be customized by using the other `init` methods.
/// If a header or footer view is not needed, use the `EmptyView` type as a placeholder.
///
public struct ScrollViewSectionExplicit<Content, Header, Footer, S: ScrollViewSectionStyle>: View where Content: View, Header: View, Footer: View {
    
    // MARK: - Properties - Public
    
    /// The background color for the section.
    @Environment(\.scrollViewSectionBackgroundColor)
    public var scrollViewSectionBackgroundColor: Color
    
    /// The container type for the section.
    @Environment(\.scrollViewSectionContainerType)
    public var scrollViewSectionContainerType: ScrollViewSectionContainerType
    
    
    public var scrollViewSectionStyle: S
    
    // MARK: - Properties - Private
    
    private var content: () -> Content
    private var header: () -> Header
    private var footer: () -> Footer
    
    // MARK: - Initialization - Public
    
    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and no header or footer.
    /// - Parameter content: The content of the section.
    public init(style: S,
                @ViewBuilder content: @escaping () -> Content) where Header == EmptyView, Footer == EmptyView {
        self.scrollViewSectionStyle = style
        
        self.content = content
        self.header = {
            EmptyView()
        }
        self.footer = {
            EmptyView()
        }
    }
    
    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and header, and no footer.
    /// - Parameters:
    ///   - content: The content of the section.
    ///   - header: The header of the section.
    public init(style: S,
                @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) where Footer == EmptyView {
        self.scrollViewSectionStyle = style
        self.content = content
        self.header = header
        self.footer = {
            EmptyView()
        }
    }
    
    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and footer, and no header.
    /// - Parameters:
    ///   - content: The content of the section.
    ///   - footer: The footer of the section.
    public init(style: S,
                @ViewBuilder content: @escaping () -> Content, @ViewBuilder footer: @escaping () -> Footer) where Header == EmptyView {
        self.scrollViewSectionStyle = style
        self.content = content
        self.header = {
            EmptyView()
        }
        self.footer = footer
    }
    
    /// Initializes a new instance of the `ScrollViewSection` struct with the given content, header, and footer.
    /// - Parameters:
    ///   - content: The content of the section.
    ///   - header: The header of the section.
    ///   - footer: The footer of the section.
    public init(style: S,
                @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header, @ViewBuilder footer: @escaping () -> Footer) {
        self.scrollViewSectionStyle = style
        self.content = content
        self.header = header
        self.footer = footer
    }
    
    // MARK: - View
    
    @ViewBuilder
    public var body: some View {
        /// Content
        ExtractMulti(
            content()
                .frame(maxWidth: .infinity, minHeight: 44.0, alignment: .leading)
        ) { children in
            if children.count > 0 {
                scrollViewSectionStyle.makeContentBody(configuration: .init(
                    label: .init(content: section(children: children))
                ))
                .background(scrollViewSectionBackgroundColor)
            } else {
                EmptyView()
//                Color.red
//                    .opacity(0.5)
                
            }
        }
    }
    
    // MARK: - Helper Methods - Private
    
    @ViewBuilder
    private func section(children: _VariadicView.Children) -> some View {
        VStack(alignment: .leading, spacing: 0.0) {
            /// Header
            scrollViewSectionStyle.makeHeaderBody(
                configuration: .init(
                    label: .init(content: header())
                )
            )
            /// Rows
            Group {
                switch scrollViewSectionContainerType {
                case .VStack:
                    VStack(alignment: .leading, spacing: 0.0) {
                        let last = children.last?.id
                        ForEach(children) { child in
                            /// Row
                            if let menuItems = child[ScrollViewRowContextMenuViewTraitKey.self] {
                                row(child: child, last: last)
                                    .contextMenu(menuItems: menuItems)
                            } else {
                                row(child: child, last: last)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .clipShape(scrollViewSectionStyle.sectionClipShape)

                case .LazyVStack:
                    LazyVStack(alignment: .leading, spacing: 0.0) {
                        let last = children.last?.id
                        ForEach(children) { child in
                            /// Row
                            if let menuItems = child[ScrollViewRowContextMenuViewTraitKey.self] {
                                row(child: child, last: last)
                                    .contextMenu(menuItems: menuItems)
                            } else {
                                row(child: child, last: last)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .clipShape(scrollViewSectionStyle.sectionClipShape)

                }
            }
//            .clipShape(scrollViewSectionStyle.sectionClipShape)
            /// Footer
            scrollViewSectionStyle.makeFooterBody(
                configuration: .init(
                    label: .init(content: footer())
                )
            )
        }
    }
    
    @ViewBuilder
    private func row(child: _VariadicView_Children.Element, last: AnyHashable?) -> some View {
        let backgroundColor: Color? = {
            if let backgroundColor = child[ScrollViewRowBackgroundColorViewTraitKey.self] {
                return backgroundColor
            } else {
                return scrollViewSectionStyle.rowBackgroundColor
            }
        }()
        
        let type: ScrollViewSectionPaddingType = {
            if let insets = child[ScrollViewRowInsetsViewTraitKey.self] {
                return .edgeInsets(insets)
            } else {
                return scrollViewSectionStyle.rowContentInsets
            }
        }()
        switch type {
        case .edgeInsets(let edgeInsets):
            child
                .padding(edgeInsets)
                .background(backgroundColor)
        case .edges(let edges, let length):
            child
                .padding(edges, length)
                .background(backgroundColor)
        }
        
        /// Divider
        if child.id != last {
            let color: Color? = {
                if let tint = child[ScrollViewRowSeparatorTintViewTraitKey.self] {
                    return tint
                } else {
                    return scrollViewSectionStyle.rowSeparatorColor
                }
            }()
            let type: ScrollViewSectionPaddingType = {
                if let insets = child[ScrollViewRowSeparatorInsetsViewTraitKey.self] {
                    return .edgeInsets(insets)
                } else {
                    return scrollViewSectionStyle.rowSeparatorInsets
                }
            }()
            switch type {
            case .edgeInsets(let edgeInsets):
                Divider()
                    .overlay(color)
                    .padding(edgeInsets)
            case .edges(let edges, let length):
                Divider()
                    .overlay(color)
                    .padding(edges, length)
                
            }
            
        }
        
    }
    
}

//import SwiftUI
//
///// The `ScrollViewSection` is a view that represents a section in a `ScrollView` SwiftUI component.
/////
///// You can customize the appearance of the section by applying a `ScrollViewSectionStyle` by using function [`.scrollViewSectionBackgroundColor(_ color: Color)`](x-source-tag://Function_ScrollViewSectionBackgroundColor) .
///// By default, the `insetGrouped` will be used.
/////
///// - Example:
/////
/////         var body: some View {
/////             ScrollView {
/////                 VStack(spacing: 0.0) {
/////                     ScrollViewSection {
/////                         Text("First row")
/////                         Text("Second row")
/////                         Text("Third row")
/////                     }
/////                 }
/////             }
/////         }
/////
///// In the example above, `ScrollViewSection` is used to group the three `Text` views together in a section.
/////
///// The `ScrollViewSection` supports a header and footer view, which can be customized by using the other `init` methods.
///// If a header or footer view is not needed, use the `EmptyView` type as a placeholder.
/////
//public struct ScrollViewSectionExplicit<Content, Header, Footer, S: ScrollViewSectionStyle>: View where Content: View, Header: View, Footer: View {
//    
//    // MARK: - Properties - Public
//    
//    /// The background color for the section.
//    @Environment(\.scrollViewSectionBackgroundColor)
//    public var scrollViewSectionBackgroundColor: Color
//    
//    /// The container type for the section.
//    @Environment(\.scrollViewSectionContainerType)
//    public var scrollViewSectionContainerType: ScrollViewSectionContainerType
//    
//    
//    public var scrollViewSectionStyle: S
//    
//    // MARK: - Properties - Private
//    
//    private var content: () -> Content
//    private var header: () -> Header
//    private var footer: () -> Footer
//    
//    // MARK: - Initialization - Public
//    
//    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and no header or footer.
//    /// - Parameter content: The content of the section.
//    public init(style: S,
//                @ViewBuilder content: @escaping () -> Content) where Header == EmptyView, Footer == EmptyView {
//        self.scrollViewSectionStyle = style
//        
//        self.content = content
//        self.header = {
//            EmptyView()
//        }
//        self.footer = {
//            EmptyView()
//        }
//    }
//    
//    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and header, and no footer.
//    /// - Parameters:
//    ///   - content: The content of the section.
//    ///   - header: The header of the section.
//    public init(style: S,
//                @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header) where Footer == EmptyView {
//        self.scrollViewSectionStyle = style
//        self.content = content
//        self.header = header
//        self.footer = {
//            EmptyView()
//        }
//    }
//    
//    /// Initializes a new instance of the `ScrollViewSection` struct with the given content and footer, and no header.
//    /// - Parameters:
//    ///   - content: The content of the section.
//    ///   - footer: The footer of the section.
//    public init(style: S,
//                @ViewBuilder content: @escaping () -> Content, @ViewBuilder footer: @escaping () -> Footer) where Header == EmptyView {
//        self.scrollViewSectionStyle = style
//        self.content = content
//        self.header = {
//            EmptyView()
//        }
//        self.footer = footer
//    }
//    
//    /// Initializes a new instance of the `ScrollViewSection` struct with the given content, header, and footer.
//    /// - Parameters:
//    ///   - content: The content of the section.
//    ///   - header: The header of the section.
//    ///   - footer: The footer of the section.
//    public init(style: S,
//                @ViewBuilder content: @escaping () -> Content, @ViewBuilder header: @escaping () -> Header, @ViewBuilder footer: @escaping () -> Footer) {
//        self.scrollViewSectionStyle = style
//        self.content = content
//        self.header = header
//        self.footer = footer
//    }
//    
//    // MARK: - View
//    
//    @ViewBuilder
//    public var body: some View {
//        /// Content
//        ExtractMulti(
//            content()
//                .frame(maxWidth: .infinity, minHeight: 44.0, alignment: .leading)
//            
//        ) { children in
//            if children.count > 0 {
//                scrollViewSectionStyle.makeContentBody(configuration: .init(
//                    label: .init(content: section(children: children))
//                ))
//                .background(scrollViewSectionBackgroundColor)
//            } else {
//                EmptyView()
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods - Private
//    
//    @ViewBuilder
//    private func section(children: _VariadicView.Children) -> some View {
//        VStack(alignment: .leading, spacing: 0.0) {
//            /// Header
//            scrollViewSectionStyle.makeHeaderBody(
//                configuration: .init(
//                    label: .init(content: header())
//                )
//            )
//            /// Rows
//            Group {
//                switch scrollViewSectionContainerType {
//                case .VStack:
//                    VStack(alignment: .leading, spacing: 0.0) {
//                        let last = children.last?.id
//                        ForEach(children) { child in
//                            /// Row
//                            if let menuItems = child[ScrollViewRowContextMenuViewTraitKey.self] {
//                                row(child: child, last: last)
//                                    .contextMenu(menuItems: menuItems)
//                            } else {
//                                row(child: child, last: last)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
////                        .fixedSize(horizontal: false, vertical: true)
//
//                    }
//                case .LazyVStack:
//                    LazyVStack(alignment: .leading, spacing: 0.0) {
//                        let last = children.last?.id
//                        ForEach(children) { child in
//                            /// Row
//                            if let menuItems = child[ScrollViewRowContextMenuViewTraitKey.self] {
//                                row(child: child, last: last)
//                                    .contextMenu(menuItems: menuItems)
//                            } else {
//                                row(child: child, last: last)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
////                        .fixedSize(horizontal: false, vertical: true)
//
//                    }
//                }
//            }
//            .clipShape(scrollViewSectionStyle.sectionClipShape)
//            /// Footer
//            scrollViewSectionStyle.makeFooterBody(
//                configuration: .init(
//                    label: .init(content: footer())
//                )
//            )
//        }
//    }
//    
//    @ViewBuilder
//    private func row(child: _VariadicView_Children.Element, last: AnyHashable?) -> some View {
//        let backgroundColor: Color? = {
//            if let backgroundColor = child[ScrollViewRowBackgroundColorViewTraitKey.self] {
//                return backgroundColor
//            } else {
//                return scrollViewSectionStyle.rowBackgroundColor
//            }
//        }()
//        /// Row
//        Group {
//            /// Child
//            Group {
//                let type: ScrollViewSectionPaddingType = {
//                    if let insets = child[ScrollViewRowInsetsViewTraitKey.self] {
//                        return .edgeInsets(insets)
//                    } else {
//                        return scrollViewSectionStyle.rowContentInsets
//                    }
//                }()
//                switch type {
//                case .edgeInsets(let edgeInsets):
//                    child
//                        .padding(edgeInsets)
//                case .edges(let edges, let length):
//                    child
//                        .padding(edges, length)
//                }
//            }
//            /// Divider
//            if child.id != last {
//                Group {
//                    let color: Color? = {
//                        if let tint = child[ScrollViewRowSeparatorTintViewTraitKey.self] {
//                            return tint
//                        } else {
//                            return scrollViewSectionStyle.rowSeparatorColor
//                        }
//                    }()
//                    let type: ScrollViewSectionPaddingType = {
//                        if let insets = child[ScrollViewRowSeparatorInsetsViewTraitKey.self] {
//                            return .edgeInsets(insets)
//                        } else {
//                            return scrollViewSectionStyle.rowSeparatorInsets
//                        }
//                    }()
//                    switch type {
//                    case .edgeInsets(let edgeInsets):
//                        Divider()
//                            .overlay(color)
//                            .padding(edgeInsets)
//                    case .edges(let edges, let length):
//                        Divider()
//                            .overlay(color)
//                            .padding(edges, length)
//                    }
//                }
//            }
//        }
//        .background(backgroundColor)
//    }
//    
//}
