//
//  ContactPickerView.swift
//  FlowerStudio
//
//  Created by night on 2025/6/21.
//

import SwiftUI

/// 聯絡人選擇器視圖
struct ContactPickerView: View {
    let contactType: ContactType
    let onContactSelected: (Contact) -> Void
    
    @StateObject private var contactManager = ContactManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddContact = false
    @State private var searchText = ""
    
    var filteredContacts: [Contact] {
        let contacts = contactManager.getContacts(for: contactType)
        if searchText.isEmpty {
            return contacts
        } else {
            return contacts.filter { contact in
                contact.name.localizedCaseInsensitiveContains(searchText) ||
                contact.phone.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜尋列
                searchBar
                
                // 聯絡人列表
                if filteredContacts.isEmpty {
                    emptyStateView
                } else {
                    contactList
                }
            }
            .navigationTitle("選擇\(contactType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddContact = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            AddContactView(contactType: contactType)
        }
    }
    
    // MARK: - 子視圖
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜尋聯絡人", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var contactList: some View {
        List {
            ForEach(filteredContacts, id: \.id) { contact in
                ContactRowView(contact: contact) {
                    contactManager.useContact(contact)
                    onContactSelected(contact)
                    dismiss()
                }
            }
            .onDelete(perform: deleteContacts)
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: contactType.iconName)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("還沒有常用\(contactType.rawValue)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("點擊右上角的 + 按鈕新增常用聯絡人")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddContact = true
            } label: {
                Label("新增聯絡人", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - 功能方法
    
    private func deleteContacts(offsets: IndexSet) {
        for index in offsets {
            let contact = filteredContacts[index]
            contactManager.deleteContact(contact)
        }
    }
}

/// 聯絡人行視圖
struct ContactRowView: View {
    let contact: Contact
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 聯絡人圖示
                Image(systemName: contact.type.iconName)
                    .font(.title2)
                    .foregroundColor(Color(contact.type.color))
                    .frame(width: 30)
                
                // 聯絡人資訊
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(contact.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if contact.isDefault {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                    }
                    
                    Text(contact.phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let email = contact.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let address = contact.address {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 使用次數
                if contact.usageCount > 0 {
                    VStack {
                        Text("\(contact.usageCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("次")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 新增聯絡人視圖
struct AddContactView: View {
    let contactType: ContactType
    
    @StateObject private var contactManager = ContactManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var selectedType: ContactType
    @State private var isDefault = false
    
    init(contactType: ContactType) {
        self.contactType = contactType
        self._selectedType = State(initialValue: contactType)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本資訊") {
                    TextField("姓名", text: $name)
                    TextField("電話", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("電子郵件（選填）", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section("其他資訊") {
                    TextField("地址（選填）", text: $address)
                    
                    Picker("聯絡人類型", selection: $selectedType) {
                        ForEach(ContactType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    
                    Toggle("設為預設聯絡人", isOn: $isDefault)
                }
            }
            .navigationTitle("新增聯絡人")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveContact()
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
            }
        }
    }
    
    private func saveContact() {
        contactManager.addContact(
            name: name,
            phone: phone,
            email: email.isEmpty ? nil : email,
            address: address.isEmpty ? nil : address,
            type: selectedType,
            isDefault: isDefault
        )
        dismiss()
    }
}

#Preview {
    ContactPickerView(contactType: .customer) { contact in
        print("Selected contact: \(contact.name)")
    }
} 