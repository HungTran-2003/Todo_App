//
//  TaskService.swift
//  Todo_App
//
//  Created by admin on 20/10/25.
//
import Foundation
internal import PostgREST
import Supabase

class TaskService {
    static let share = TaskService()

    private let keyChain = KeychainManager.share

    init() {}

    func fetchData() async throws -> [Tasks] {

        let data: [Tasks] = try await SupabaseManager.shared.client
            .from("Task")
            .select("*")
            .execute()
            .value
        return data
    }

    func addTask(task: Tasks) async throws -> Tasks {

        let data: Tasks = try await SupabaseManager.shared.client
            .from("Task")
            .insert(task)
            .select()
            .single()
            .execute()
            .value

        return data
    }

    func updateTask(task: Tasks) async throws -> Tasks {


        let data: Tasks = try await SupabaseManager.shared.client
            .from("Task")
            .update(task)
            .eq("id", value: task.id)
            .select()
            .single()
            .execute()
            .value

        return data
    }
    
    func deleteTask(task: Tasks) async throws {
        guard let id = task.id else {
            throw NSError(domain: "TaskError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Could not find the task to delete"])
        }
        
        let response = try await SupabaseManager.shared.client
                .from("Task")
                .delete()
                .eq("id", value: id)
                .execute()
    }
}
