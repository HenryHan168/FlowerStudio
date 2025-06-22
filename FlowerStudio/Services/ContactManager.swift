//
//  ContactManager.swift
//  FlowerStudio
//
//  Created by night on 2025/6/21.
//

import Foundation
import SwiftData

/// 常用聯絡人管理器
@MainActor
class ContactManager: ObservableObject {
    static let shared = ContactManager()
    
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    /// 設置 ModelContext
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadContacts()
    }
    
    /// 載入所有聯絡人
    func loadContacts() {
        guard let context = modelContext else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let descriptor = FetchDescriptor<Contact>()
            let allContacts = try context.fetch(descriptor)
            
            // 手動排序，因為 SwiftData 的 SortDescriptor 有限制
            contacts = allContacts.sorted { contact1, contact2 in
                // 首先按是否為預設排序
                if contact1.isDefault != contact2.isDefault {
                    return contact1.isDefault
                }
                // 然後按使用次數排序
                if contact1.usageCount != contact2.usageCount {
                    return contact1.usageCount > contact2.usageCount
                }
                // 然後按最後使用時間排序
                if let date1 = contact1.lastUsedAt, let date2 = contact2.lastUsedAt {
                    return date1 > date2
                } else if contact1.lastUsedAt != nil {
                    return true
                } else if contact2.lastUsedAt != nil {
                    return false
                }
                // 最後按名字排序
                return contact1.name < contact2.name
            }
        } catch {
            print("❌ 載入聯絡人失敗: \(error)")
        }
    }
    
    /// 新增聯絡人
    func addContact(
        name: String,
        phone: String,
        email: String? = nil,
        address: String? = nil,
        type: ContactType,
        isDefault: Bool = false
    ) {
        guard let context = modelContext else { return }
        
        // 如果設為預設，先取消其他預設聯絡人
        if isDefault {
            clearDefaultContacts(for: type)
        }
        
        let contact = Contact(
            name: name,
            phone: phone,
            email: email,
            address: address,
            type: type,
            isDefault: isDefault
        )
        
        context.insert(contact)
        
        do {
            try context.save()
            loadContacts()
            print("✅ 聯絡人新增成功: \(name)")
        } catch {
            print("❌ 聯絡人新增失敗: \(error)")
        }
    }
    
    /// 更新聯絡人
    func updateContact(
        _ contact: Contact,
        name: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        type: ContactType? = nil,
        isDefault: Bool? = nil
    ) {
        guard let context = modelContext else { return }
        
        // 如果設為預設，先取消其他預設聯絡人
        if let isDefault = isDefault, isDefault, let type = type ?? Optional(contact.type) {
            clearDefaultContacts(for: type, except: contact)
        }
        
        contact.update(
            name: name,
            phone: phone,
            email: email,
            address: address,
            type: type,
            isDefault: isDefault
        )
        
        do {
            try context.save()
            loadContacts()
            print("✅ 聯絡人更新成功: \(contact.name)")
        } catch {
            print("❌ 聯絡人更新失敗: \(error)")
        }
    }
    
    /// 刪除聯絡人
    func deleteContact(_ contact: Contact) {
        guard let context = modelContext else { return }
        
        context.delete(contact)
        
        do {
            try context.save()
            loadContacts()
            print("✅ 聯絡人刪除成功: \(contact.name)")
        } catch {
            print("❌ 聯絡人刪除失敗: \(error)")
        }
    }
    
    /// 使用聯絡人（更新使用記錄）
    func useContact(_ contact: Contact) {
        guard let context = modelContext else { return }
        
        contact.updateUsage()
        
        do {
            try context.save()
            loadContacts()
        } catch {
            print("❌ 更新聯絡人使用記錄失敗: \(error)")
        }
    }
    
    /// 獲取指定類型的聯絡人
    func getContacts(for type: ContactType) -> [Contact] {
        return contacts.filter { contact in
            contact.type == type || contact.type == .both
        }
    }
    
    /// 獲取預設聯絡人
    func getDefaultContact(for type: ContactType) -> Contact? {
        return contacts.first { contact in
            contact.isDefault && (contact.type == type || contact.type == .both)
        }
    }
    
    /// 清除指定類型的預設聯絡人
    private func clearDefaultContacts(for type: ContactType, except: Contact? = nil) {
        guard let context = modelContext else { return }
        
        let contactsToUpdate = contacts.filter { contact in
            contact.isDefault &&
            (contact.type == type || contact.type == .both) &&
            contact != except
        }
        
        for contact in contactsToUpdate {
            contact.isDefault = false
            contact.updatedAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            print("❌ 清除預設聯絡人失敗: \(error)")
        }
    }
    
    /// 從訂單資訊快速新增聯絡人
    func quickAddFromOrder(
        customerName: String,
        customerPhone: String,
        customerEmail: String?,
        recipientName: String,
        recipientPhone: String,
        deliveryAddress: String?
    ) {
        // 檢查是否已存在相同的聯絡人
        let existingCustomer = contacts.first { contact in
            contact.name == customerName && contact.phone == customerPhone
        }
        
        let existingRecipient = contacts.first { contact in
            contact.name == recipientName && contact.phone == recipientPhone
        }
        
        // 如果訂購人和收件人是同一人，創建 both 類型
        if customerName == recipientName && customerPhone == recipientPhone {
            if existingCustomer == nil {
                addContact(
                    name: customerName,
                    phone: customerPhone,
                    email: customerEmail,
                    address: deliveryAddress,
                    type: .both
                )
            }
        } else {
            // 分別創建訂購人和收件人
            if existingCustomer == nil {
                addContact(
                    name: customerName,
                    phone: customerPhone,
                    email: customerEmail,
                    type: .customer
                )
            }
            
            if existingRecipient == nil {
                addContact(
                    name: recipientName,
                    phone: recipientPhone,
                    address: deliveryAddress,
                    type: .recipient
                )
            }
        }
    }
} 