angular.module('radsticksApp')
  .controller 'DashboardCtrl',
    ($scope, Auth, Notifications, Snippet, $modal) ->
      $scope.Auth = Auth
      $scope.Notifications = Notifications

      Auth.mustBeLoggedIn()

      # State
      $scope.snippets = []

      # Loading snippets
      $scope.loadSnippets = () ->
        Snippet.list()
          .then (snippetData) ->
            $scope.snippets = snippetData

      # Creating new snippets
      $scope.showNewSnippetModal = () ->
        modal = $modal.open(
          templateUrl: 'static/views/new_snippet.html'
          controller: NewSnippetCtrl
        )

        modal.result.then (newSnippet) ->
          Snippet.create(newSnippet).then (result) ->
            $scope.snippets.unshift(result)

      # Editing Snippets
      $scope.showEditSnippetModal = (index) ->
        modal = $modal.open(
          templateUrl: 'static/views/edit_snippet.html'
          controller: EditSnippetCtrl
          resolve:
            snippetData: () ->
              $scope.snippets[index]
        )

        modal.result.then (updatedSnippet) ->
          Snippet.update(updatedSnippet)
            .then (result) ->
              Notifications.success('Snippet updated')
              # move to top of list
              index = $scope.snippets.indexOf(updatedSnippet)
              $scope.snippets.splice(index, 1)
              $scope.snippets.unshift(result)

      $scope.deleteSnippet = (index) ->
        if confirm('Delete this snippet?')
          snippetData = $scope.snippets[index]
          Snippet.destroy(snippetData.id)
            .then (result) ->
              if result
                Notifications.success('Snippet deleted')
                $scope.snippets.splice(index, 1)
              else
                Notifications.error('Something went wrong')

      # load page
      $scope.loadSnippets()


# modal controllers
NewSnippetCtrl = ($scope, $modalInstance) ->

  $scope.snippet =
    content: ""
    tags: []

  $scope.ok = () ->
    tags = (tag.text for tag in $scope.snippet.tags)
    result =
      content: $scope.snippet.content
      tags: tags
    console.log result
    $modalInstance.close(result)

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')


EditSnippetCtrl = ($scope, $modalInstance, snippetData) ->

  t = []
  for s in snippetData.tags
    t.push({text: s})

  $scope.snippet =
    content: snippetData.content
    tags: t

  $scope.ok = () ->
    tags = (tag.text for tag in $scope.snippet.tags)
    result = snippetData
    result.content = $scope.snippet.content
    result.tags = tags

    $modalInstance.close(result)

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')


