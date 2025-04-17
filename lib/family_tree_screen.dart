import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/family_member.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart';

class FamilyTreeScreen extends StatefulWidget {
  final AuthService authService;

  const FamilyTreeScreen({super.key, required this.authService});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  final Graph graph = Graph();
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  bool isLoading = true;
  List<FamilyMember> members = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
    builder
      ..siblingSeparation =
          150 // Space between siblings
      ..levelSeparation =
          200 // Vertical space between levels
      ..subtreeSeparation =
          150 // Space between different subtrees
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final loadedMembers = await widget.authService.getFamilyMembers();
      if (kDebugMode) {
        print('Loaded members count: ${loadedMembers.length}');
        print('Loaded members: $loadedMembers');
      }
      setState(() {
        members = loadedMembers;
        _buildTree();
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading family members: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  String? findRootId() {
    // Find the current user's ID
    final currentUserId = widget.authService.userInfo?['uid'];
    if (currentUserId == null) return null;

    // Find the current user's node
    final currentUser = members.firstWhere(
      (m) => m.fromPersonId == currentUserId && m.relationshipType == 'ӨӨРӨӨ',
      orElse: () => members.first,
    );

    return currentUser.fromPersonId;
  }

  void _buildTree() {
    // Clear existing nodes and edges
    graph.nodes.clear();
    graph.edges.clear();

    if (members.isEmpty) {
      if (kDebugMode) {
        print('No members to build tree');
      }
      return;
    }

    if (kDebugMode) {
      print('Building tree with ${members.length} members');
    }

    // Create nodes for each family member
    final Map<String, Node> nodeMap = {};
    for (var member in members) {
      // Create a unique node ID using fromPersonId and name
      final nodeId = '${member.fromPersonId}_${member.name}';
      final node = Node.Id(nodeId);
      nodeMap[nodeId] = node;
      graph.addNode(node);
      if (kDebugMode) {
        print('Added node for member: ${member.name} with ID: $nodeId');
      }
    }

    // Find the root node (current user)
    final rootId = findRootId();
    if (rootId == null) {
      if (kDebugMode) {
        print('Could not find root node');
      }
      return;
    }

    final rootNode =
        nodeMap['${rootId}_${members.firstWhere((m) => m.fromPersonId == rootId).name}'];
    if (rootNode == null) {
      if (kDebugMode) {
        print('Root node not found in nodeMap');
      }
      return;
    }

    // First, find the father node
    final father = members.firstWhere(
      (m) => m.relationshipType == 'ЭЦЭГ' || m.relationshipType == 'father',
      orElse: () => members.first,
    );
    final fatherNode = nodeMap['${father.fromPersonId}_${father.name}'];

    // Add edges based on relationships
    for (var member in members) {
      if (member.relationshipType == 'ӨӨРӨӨ') continue; // Skip self-reference

      final fromNodeId = '${member.fromPersonId}_${member.name}';
      final fromNode = nodeMap[fromNodeId];

      if (fromNode == null) {
        if (kDebugMode) {
          print('Node not found for member: ${member.name}');
        }
        continue;
      }

      if (kDebugMode) {
        print(
          'Processing relationships for member: ${member.name} with type: ${member.relationshipType}',
        );
      }

      // Add edges based on relationship type
      final relationshipType = member.relationshipType.toLowerCase();
      if (relationshipType == 'эцэг' || relationshipType == 'father') {
        // Father to child relationship (inheritance)
        graph.addEdge(fromNode, rootNode);
      } else if (relationshipType == 'эх' || relationshipType == 'mother') {
        // Mother to child relationship
        graph.addEdge(fromNode, rootNode);
      } else if (relationshipType == 'хүүхэд' ||
          relationshipType == 'children') {
        // Child to parent relationship
        graph.addEdge(rootNode, fromNode);
      } else if (relationshipType == 'ах' ||
          relationshipType == 'brothers' ||
          relationshipType == 'эгч' ||
          relationshipType == 'sisters' ||
          relationshipType == 'дүү' ||
          relationshipType == 'youngsiblings') {
        // Sibling relationships
        if (fatherNode != null) {
          graph.addEdge(fatherNode, fromNode);
        }
      } else if (relationshipType == 'гэр бүл' ||
          relationshipType == 'spouse') {
        // Spouse relationship
        graph.addEdge(rootNode, fromNode);
      } else if (relationshipType == 'өвөө' ||
          relationshipType == 'grandfather' ||
          relationshipType == 'эмээ' ||
          relationshipType == 'grandmother') {
        // Grandparent relationships
        if (fatherNode != null) {
          graph.addEdge(fromNode, fatherNode);
        }
      }
    }

    if (kDebugMode) {
      print('Tree building completed');
      print('Total nodes: ${graph.nodes.length}');
      print('Total edges: ${graph.edges.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ургийн мод',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(150),
                minScale: 0.1,
                maxScale: 5.0,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    builder,
                    TreeEdgeRenderer(builder),
                  ),
                  paint:
                      Paint()
                        ..color = Colors.green
                        ..strokeWidth = 2
                        ..style = PaintingStyle.stroke,
                  builder: (Node node) {
                    final member = members.firstWhere(
                      (m) => '${m.fromPersonId}_${m.name}' == node.key?.value,
                      orElse: () => members.first,
                    );
                    return _buildFamilyMemberNode(member);
                  },
                ),
              ),
    );
  }

  Widget _buildFamilyMemberNode(FamilyMember member) {
    // Map English relationship types to Mongolian
    String getMongolianRelationshipType(String type) {
      switch (type.toLowerCase()) {
        case 'father':
          return 'ЭЦЭГ';
        case 'mother':
          return 'ЭХ';
        case 'children':
          return 'ХҮҮХЭД';
        case 'brothers':
          return 'АХ';
        case 'sisters':
          return 'ЭГЧ';
        case 'youngsiblings':
          return 'ДҮҮ';
        case 'spouse':
          return 'ГЭР БҮЛ';
        case 'grandfather':
          return 'ӨВӨӨ';
        case 'grandmother':
          return 'ЭМЭЭ';
        default:
          return type;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green,
            child: Icon(
              member.gender == 'Эр' ? Icons.male : Icons.female,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${member.lastname ?? ''} ${member.name}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            'Төрсөн: ${member.birthdate.year}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            getMongolianRelationshipType(member.relationshipType),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
