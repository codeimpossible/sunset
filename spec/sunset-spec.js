var Sunset;

Sunset = require('../lib/sunset');

describe("Sunset", function() {
  var activationPromise, ref, workspaceElement;
  ref = [], workspaceElement = ref[0], activationPromise = ref[1];
  beforeEach(function() {
    workspaceElement = atom.views.getView(atom.workspace);
    return activationPromise = atom.packages.activatePackage('sunset');
  });
  return describe("when the sunset:toggle event is triggered", function() {
    it("hides and shows the modal panel", function() {
      expect(workspaceElement.querySelector('.sunset')).not.toExist();
      atom.commands.dispatch(workspaceElement, 'sunset:toggle');
      waitsForPromise(function() {
        return activationPromise;
      });
      return runs(function() {
        var sunsetElement, sunsetPanel;
        expect(workspaceElement.querySelector('.sunset')).toExist();
        sunsetElement = workspaceElement.querySelector('.sunset');
        expect(sunsetElement).toExist();
        sunsetPanel = atom.workspace.panelForItem(sunsetElement);
        expect(sunsetPanel.isVisible()).toBe(true);
        atom.commands.dispatch(workspaceElement, 'sunset:toggle');
        return expect(sunsetPanel.isVisible()).toBe(false);
      });
    });
    return it("hides and shows the view", function() {
      jasmine.attachToDOM(workspaceElement);
      expect(workspaceElement.querySelector('.sunset')).not.toExist();
      atom.commands.dispatch(workspaceElement, 'sunset:toggle');
      waitsForPromise(function() {
        return activationPromise;
      });
      return runs(function() {
        var sunsetElement;
        sunsetElement = workspaceElement.querySelector('.sunset');
        expect(sunsetElement).toBeVisible();
        atom.commands.dispatch(workspaceElement, 'sunset:toggle');
        return expect(sunsetElement).not.toBeVisible();
      });
    });
  });
});
