import { EditProject } from '@atomist/rug/operations/ProjectEditor';
import { Project } from '@atomist/rug/model/Project';
import { Pattern } from '@atomist/rug/operations/RugOperation';
import { Editor, Parameter, Tags } from '@atomist/rug/operations/Decorators';

/**
 * Sample TypeScript editor used by AddBumpVersion.
 */
@Editor("BumpVersion", "bump the version of this Elm project")
@Tags("elm", "version")
export class BumpVersion implements EditProject {

    @Parameter({
        displayName: "version component",
        description: "how bumped is it? major/minor/patch",
        pattern: Pattern.any, // TODO: regex
        validInput: "major | minor | patch",
        minLength: 1,
        maxLength: 5,
        required: false
    })
    component: string = "patch";

    edit(project: Project) {
        let versionRegex = /"version": "(\d+)\.(\d+)\.(\d+)"/;
        let manifest = project.findFile("elm-package.json");
        let versionMatch = versionRegex.exec(manifest.content);
        if (!versionMatch) {
            throw "Unable to parse current version. I only increment a nice simple 1.2.3 format. Content " + manifest.content
        }

        let major = parseInt(versionMatch[1]);
        let minor = parseInt(versionMatch[2]);
        let patch = parseInt(versionMatch[3]);
        if (this.component == "major") {
            major = major + 1;
        } else if (this.component == "minor") {
            minor = minor + 1;
        } else if (this.component == "patch") {
            patch = patch + 1;
        } else {
            throw `Unknown version component '${this.component}'. Should be major|minor|patch`;
        }

        let newVersion = `"${major}.${minor}.${patch}"`;
        let newContent = manifest.content.replace(versionRegex, `"version": ${newVersion}`)
        manifest.setContent(newContent);

        console.log(`Bumping version to ${newVersion}`);

        let versionInfoInElm = project.findFile("src/VersionInfo.elm");
        versionInfoInElm.setContent(versionInfoInElm.content.replace(/version = ".*"/, `version = ${newVersion}`));
    }
}

export const bumpVersion = new BumpVersion();
