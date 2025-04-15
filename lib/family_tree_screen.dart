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
          200 // Increase the space between siblings
      ..levelSeparation =
          300 // Increase the vertical space between levels
      ..subtreeSeparation =
          200 // Increase space between different subtrees
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
      print('Current user ID: ${widget.authService.userInfo?['uid']}');
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

    // Find the current user's node
    final currentUser = members.firstWhere(
      (m) => m.fromPersonId == widget.authService.userInfo?['uid'],
      orElse: () => members.first,
    );
    final currentUserId = '${currentUser.fromPersonId}_${currentUser.name}';
    final currentUserNode = nodeMap[currentUserId];

    // Add edges based on relationships
    for (var member in members) {
      final fromNodeId = '${member.fromPersonId}_${member.name}';
      final fromNode = nodeMap[fromNodeId];
      if (fromNode == null) {
        if (kDebugMode) {
          print(
            'Node not found for member: ${member.name} with ID: $fromNodeId',
          );
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
      if (relationshipType == 'ЭЦЭГ' ||
          relationshipType == 'father' ||
          relationshipType == 'ЭХ' ||
          relationshipType == 'mother') {
        // Parent to child relationship
        if (currentUserNode != null) {
          graph.addEdge(fromNode, currentUserNode);
          if (kDebugMode) {
            print(
              'Added parent-child edge from ${member.name} to current user',
            );
          }
        }
      } else if (relationshipType == 'ХҮҮХЭД' ||
          relationshipType == 'children') {
        // Child to parent relationship
        if (currentUserNode != null) {
          graph.addEdge(currentUserNode, fromNode);
          if (kDebugMode) {
            print(
              'Added child-parent edge from current user to ${member.name}',
            );
          }
        }
      } else if (relationshipType == 'АХ' ||
          relationshipType == 'brothers' ||
          relationshipType == 'ЭГЧ' ||
          relationshipType == 'sisters' ||
          relationshipType == 'ДҮҮ' ||
          relationshipType == 'youngsiblings') {
        // Sibling relationships
        if (currentUserNode != null) {
          graph.addEdge(currentUserNode, fromNode);
          if (kDebugMode) {
            print('Added sibling edge from current user to ${member.name}');
          }
        }
      } else if (relationshipType == 'гэр бүл' ||
          relationshipType == 'spouse') {
        // Spouse relationship
        if (currentUserNode != null) {
          graph.addEdge(currentUserNode, fromNode);
          if (kDebugMode) {
            print('Added spouse edge from current user to ${member.name}');
          }
        }
      } else if (relationshipType == 'өвөө' ||
          relationshipType == 'grandfather' ||
          relationshipType == 'эмээ' ||
          relationshipType == 'grandmother') {
        // Grandparent relationships
        if (currentUserNode != null) {
          graph.addEdge(fromNode, currentUserNode);
          if (kDebugMode) {
            print(
              'Added grandparent-grandchild edge from ${member.name} to current user',
            );
          }
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
                boundaryMargin: const EdgeInsets.all(
                  150,
                ), // Increase the boundary margin
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
            radius: 25, // Increased radius for more space
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
