import 'package:solo1/features/auth/domain/entities/agent_entity.dart';
import 'package:solo1/features/auth/domain/repositories/agent_repository.dart';
import 'package:solo1/features/auth/data/datasources/local/agent_local_datasource.dart';
import 'package:solo1/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:solo1/features/auth/data/datasources/remote/agent_remote_datasource.dart';
import 'package:solo1/features/auth/data/models/agent_model.dart';
import 'package:flutter/foundation.dart';

class AgentRepositoryImpl implements AgentRepository {
  final AgentLocalDataSource local;
  final AuthRemoteDataSource auth;
  final AgentRemoteDataSourceBase remote;
  AgentRepositoryImpl({AgentLocalDataSource? local, AuthRemoteDataSource? auth, AgentRemoteDataSourceBase? remote})
      : local = local ?? AgentLocalDataSource(),
        auth = auth ?? AuthRemoteDataSource(),
        remote = remote ?? AgentRemoteDataSource();

  @override
  Future<AgentEntity?> getCurrent() async {
    final l = await local.loadLocal();
    if (l != null) {
      return AgentEntity(uid: l.uid, fullName: l.fullName, phone: l.phone, email: l.email, agentId: l.agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(l.createdAt), role: l.role, status: l.status);
    }
    final uid = auth.currentUid();
    if (uid != null) {
      final r = await remote.getAgent(uid);
      if (r != null) {
        await local.saveLocal(r);
        return AgentEntity(uid: r.uid, fullName: r.fullName, phone: r.phone, email: r.email, agentId: r.agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt), role: r.role, status: r.status);
      }
    }
    return null;
  }

  @override
  Future<AgentEntity> register({required String fullName, required String phone, required String email, required String password}) async {
    final uid = await auth.register(email, password);
    final now = DateTime.now().millisecondsSinceEpoch;
    final agentId = 'AGT-$now';
    final desiredRole = email.toLowerCase() == 'admin@solo1.app'
        ? 'admin'
        : (email.toLowerCase() == 'moderator@solo1.app' ? 'moderator' : 'agent');
    final m = AgentModel(uid: uid, fullName: fullName, phone: phone, email: email, agentId: agentId, createdAt: now, role: desiredRole, status: 'active');
    try {
      await remote.saveAgent(m);
    } catch (_) {}
    await local.saveLocal(m);
    return AgentEntity(uid: uid, fullName: fullName, phone: phone, email: email, agentId: agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(now), role: desiredRole, status: 'active');
  }

  @override
  Future<AgentEntity> login({required String email, required String password}) async {
    if (!kReleaseMode && email.toLowerCase() == 'test@solo1.app' && password == '12345678') {
      final now = DateTime.now().millisecondsSinceEpoch;
      final m = AgentModel(
        uid: 'uid-test',
        fullName: 'Test User',
        phone: '',
        email: email,
        agentId: 'TEST-$now',
        createdAt: now,
        role: 'agent',
        status: 'test',
      );
      await local.saveLocal(m);
      return AgentEntity(
        uid: m.uid,
        fullName: m.fullName,
        phone: m.phone,
        email: m.email,
        agentId: m.agentId,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m.createdAt),
        role: m.role,
        status: m.status,
      );
    }
    final l = await local.loadLocal();
    if (l != null) {
      return AgentEntity(uid: l.uid, fullName: l.fullName, phone: l.phone, email: l.email, agentId: l.agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(l.createdAt), role: l.role, status: l.status);
    }
    final uid = await auth.login(email, password);
    final r = await remote.getAgent(uid);
    final desiredRole = email.toLowerCase() == 'admin@solo1.app'
        ? 'admin'
        : (email.toLowerCase() == 'moderator@solo1.app' ? 'moderator' : 'agent');
    if (r != null) {
      final updated = AgentModel(
        uid: r.uid,
        fullName: r.fullName,
        phone: r.phone,
        email: r.email,
        agentId: r.agentId,
        createdAt: r.createdAt,
        role: desiredRole,
        status: r.status,
      );
      try {
        if (r.role != desiredRole) {
          await remote.saveAgent(updated);
        }
      } catch (_) {}
      await local.saveLocal(updated);
      return AgentEntity(uid: updated.uid, fullName: updated.fullName, phone: updated.phone, email: updated.email, agentId: updated.agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(updated.createdAt), role: updated.role, status: updated.status);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final fallback = AgentModel(uid: uid, fullName: email.split('@').first, phone: '', email: email, agentId: 'AGT-$now', createdAt: now, role: desiredRole, status: 'active');
    try {
      await remote.saveAgent(fallback);
    } catch (_) {}
    await local.saveLocal(fallback);
    return AgentEntity(uid: uid, fullName: fallback.fullName, phone: fallback.phone, email: email, agentId: fallback.agentId, createdAt: DateTime.fromMillisecondsSinceEpoch(now), role: desiredRole, status: 'active');
  }

  @override
  Future<void> sync() async {
    final uid = auth.currentUid();
    if (uid == null) return;
    final r = await remote.getAgent(uid);
    if (r != null) {
      await local.saveLocal(r);
    }
  }
}